function load_measured_data(measured_data_path = joinpath(DEFAULT_ARTIFACTS_DIR, "Calibration_data"))

    cwm_traits_df = CSV.read(joinpath(measured_data_path, "CWM_Traits.csv"), DataFrame)
    biomass_df = CSV.read(joinpath(measured_data_path, "Biomass.csv"), DataFrame)

    plotIDs = unique(biomass_df.plotID)
    data = Dict()

    for p in plotIDs
        ########## Biomass data
        biomass_sub = @chain biomass_df begin
            @subset :plotID .== p
            @orderby :date
        end
        nt = nrow(biomass_sub)

        biomass = Array{typeof(1.0u"kg/ha")}(undef, nt)
        cutting_height = Array{typeof(1.0u"m")}(undef, nt)

        for (i,r) in enumerate(eachrow(biomass_sub))
            biomass[i] = r.biomass * u"kg/ha"
            cutting_height[i] = r.cutting_height * u"m"
        end

        ts = biomass_sub.date
        biomassdim = DimArray(biomass, (; t = ts), name = "biomass")
        cutting_heightdim = DimArray(cutting_height, (; t = ts), name = "cutting_height")

        ########## CWM trait data
        cwm_traits_sub = @chain cwm_traits_df begin
            @subset :plotID .== p
            @orderby :date
        end
        nt = nrow(cwm_traits_sub)

        amc = Array{Float64}(undef, nt)
        rsa = Array{typeof(1.0u"m^2/g")}(undef, nt)
        lnc = Array{typeof(1.0u"mg/g")}(undef, nt)
        sla = Array{typeof(1.0u"m^2/g")}(undef, nt)
        maxheight = Array{typeof(1.0u"m")}(undef, nt)
        abp = Array{Float64}(undef, nt)
        fdis = Array{Float64}(undef, nt)

        cwm_traits = Dict()
        for (i,r) in enumerate(eachrow(cwm_traits_sub))
            amc[i] = r.amc
            rsa[i] = r.rsa * u"m^2/g"
            lnc[i] = r.lnc * u"mg/g"
            sla[i] = r.sla * u"m^2/g"
            maxheight[i] = r.maxheight * u"m"
            abp[i] = r.abp
            fdis[i] = r.fdis
        end

        ts = cwm_traits_sub.date
        amcdim = DimArray(amc, (; t = ts), name = "amc")
        rsadim = DimArray(rsa, (; t = ts), name = "rsa")
        lncdim = DimArray(lnc, (; t = ts), name = "lnc")
        sladim = DimArray(sla, (; t = ts), name = "sla")
        maxheightdim = DimArray(maxheight, (; t = ts), name = "maxheight")
        abpdim = DimArray(abp, (; t = ts), name = "abp")
        fdisdim = DimArray(fdis, (; t = ts), name = "fdis")

        st1 = DimStack(biomassdim, cutting_heightdim)
        st2 = DimStack(amcdim, rsadim, lncdim, sladim, maxheightdim, abpdim, fdisdim)
        data[Symbol(p)] = (; CWM_traits = st2, Cut_biomass = st1)
    end

    global measured_data = NamedTuple(data)

    return nothing
end
