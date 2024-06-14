
# Preprocessing of FAO dataset
 
1. the [PCSE python package](https://github.com/ajwdewit/pcse/) was downloaded
2. data is stored in `yaml` files: [PCSE python package/exp/LINGRA_FAO](https://github.com/ajwdewit/pcse/tree/master/exp/LINGRA_FAO)
3. data was converted to `csv` files, scripts is adapted from: [PCSE python package: process_experiment_collections.py](https://github.com/ajwdewit/pcse/blob/f456aa83547542be3006e548361f85ea22352920/exp/process_experiment_collections.py)
4. these `csv` files are used to calibrate parameters of the `GrasslandTraitSim.jl` model, these files are saved under `/assets/data/fao_calibration`

```python
import pickle
import yaml
import pandas as pd
from pathlib import Path
from pcse.base import ParameterProvider, WeatherDataProvider, WeatherDataContainer
from pcse.util import reference_ET

class YAMLWeatherDataProvider(WeatherDataProvider):
    def __init__(self, yaml_weather):
        super().__init__()
        for weather in yaml_weather:
            if "SNOWDEPTH" in weather:
                weather.pop("SNOWDEPTH")
            if "ET0" not in weather:
                E0, ES0, ET0 = reference_ET(**weather)
                weather["ET0"] = ET0/10.
                weather["ES0"] = ES0/10.
                weather["E0"] = E0/10.
            wdc = WeatherDataContainer(**weather)
            self._store_WeatherDataContainer(wdc, wdc.DAY)

def load_experiment(f):
    f_cache = Path(str(f) + ".cache")
    if f_cache.exists():
        if f_cache.stat().st_mtime > f.stat().st_mtime:
            with open(f_cache, "rb") as fp:
                r = pickle.load(fp)
            return r

    # If no or outdated cache, (re)load YAML file
    r = yaml.safe_load(open(f))
    with open(f_cache, "wb") as fp:
        pickle.dump(r, fp, protocol=pickle.HIGHEST_PROTOCOL)

    return r

def export_weather(obj):
    df = pd.DataFrame(YAMLWeatherDataProvider(obj).export())
    
    # IRRAD is in J/m2/day, convert to MJ/ha/day
    # see https://doi.org/10.1016/j.jag.2022.102724
    fraction_RAD_PAR = 0.45
    df['PAR'] = df['IRRAD'] * 10000 / 1000000 * fraction_RAD_PAR
    
    # ET0 is in cm/day, convert to mm/day
    df['PET'] = df['ET0'] * 10
    
    # RAIN is in cm/day, convert to mm/day
    df['precipitation'] = df['RAIN'] * 10
    
    # TMIN and TMAX are already in °C
    df['temperature'] = (df.TMIN + df.TMAX) / 2
    
    return df[['DAY', 'temperature', 'precipitation', 'PAR', 'PET']]

def load_mowing(agro):
    mowing_dates = []
    remaining_biomass = []

    for i, _ in enumerate(agro):
        sub_element = agro[i][next(iter(agro[i]))]
        
        if sub_element == None:
            continue
            
        mowing_table = sub_element['TimedEvents'][0]['events_table']
        
        for i, m in enumerate(mowing_table):
            k = list(m.keys())[0]
            mowing_dates.append(k)
            remaining_biomass.append(mowing_table[i][k]['biomass_remaining'])

    return pd.DataFrame({'date': mowing_dates, 'biomass_remaining': remaining_biomass})

def load_everything(fname, idx=0):
    f = exp_dir / fname
    yaml_exp = load_experiment(f)
    
    ## Metadata
    metadata = yaml_exp['Metadata']
    metadata_sub = {k: v for k, v in metadata.items() if k in ['crop', 'location', 'experiment_type']}
    df_metadata = pd.DataFrame(metadata_sub, index = [0])
    
    ## Parameters
    params = ParameterProvider(cropdata=yaml_exp["ModelParameters"])
    p = {}
    p_keys = ['SLA', 'LAIinit', 'LAIcrit', 'LAIafterHarvest', 'LUEmax', 'TempBase'] #'LUEreductionSoilTempTB'
    for k in p_keys:
        p[k] = params[k]
    df_param = pd.DataFrame(p, index = [0])

    ## Parameters and Metadata in one dataframe
    df_site = pd.concat([df_metadata, df_param], axis=1)
    df_site['id'] = idx
    
    ## Weather data
    df_weather = export_weather(yaml_exp["WeatherVariables"])
    df_weather = df_weather.rename(columns={"DAY": "date"})
    df_weather['id'] = idx

    ## Observational data
    df_observations = pd.DataFrame(yaml_exp["TimeSeriesObservations"])
    df_observations = df_observations.rename(columns={"day": "date"})
    df_observations['id'] = idx
    
    ## Mowing
    df_mowing = load_mowing(yaml_exp["Agromanagement"])
    df_mowing['id'] = idx
    
    return df_site, df_weather, df_observations, df_mowing


def load_all_sites():
    df_site = pd.DataFrame()
    df_weather = pd.DataFrame()
    df_observations = pd.DataFrame()
    df_mowing = pd.DataFrame()
    
    id = 1
    for fname in sorted(exp_dir.iterdir()):
        if fname.suffix != ".yaml":
            continue
        print(fname)
        
        df_site_, df_weather_, df_observations_, df_mowing_ = load_everything(fname, idx=id)
        id = id + 1
        
        df_site = pd.concat([df_site, df_site_])
        df_weather = pd.concat([df_weather, df_weather_])
        df_observations = pd.concat([df_observations, df_observations_])
        df_mowing = pd.concat([df_mowing, df_mowing_])
        
    df_site.to_csv("sites.csv", index=False)
    df_weather.to_csv("climate.csv", index=False)
    df_observations.to_csv("observations.csv", index=False)
    df_mowing.to_csv("mowing.csv", index=False)
    
###########################################################################
## Run
###########################################################################
exp_dir = Path.cwd() / "python_pcse" / "exp" / "LINGRA_FAO/"
load_all_sites()
```