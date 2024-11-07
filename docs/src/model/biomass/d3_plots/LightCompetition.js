import * as d3 from 'd3';
    
export function lightCompetitionSimplePlot() {
    const svg_width = 700, svg_height = 400;
    const margin = { top: 0, right: 110, bottom: 50, left: 70 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#light_competition_graph")
        .attr("viewBox", `0 0 ${svg_width} ${svg_height}`)
        .attr("preserveAspectRatio", "xMidYMid meet")
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const max_x = 1.5;
    const max_y = 2.5;
    const x = d3.scaleLinear().range([0, width]).domain([0, max_x]); 
    const y = d3.scaleLinear().range([height, 0]).domain([0, max_y]); 

    svg.append("g")
        .attr("class", "x-axis")
        .attr("transform", `translate(0, ${height})`)
        .call(d3.axisBottom(x));

    svg.append("g")
        .attr("class", "y-axis")
        .call(d3.axisLeft(y));

    svg.append("text")
        .attr("class", "x-label")
        .attr("x", width / 2)
        .attr("y", height + 40)
        .attr("text-anchor", "middle")
        .text("Height species 1 [m]");

    svg.append("text")
        .attr("class", "y-label")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("transform", "rotate(-90)")
        .attr("text-anchor", "middle")
        .text("Height competition factor [-]");
    
    function calcData(beta_H) {
        const otherH = 0.4;
        const data = [];
        for (let H = 0; H <= max_x; H += max_x/200) {
            data.push({ 
                H: H, 
                Hcomp1: (H / ((otherH+H)/2)) ** beta_H,
                Hcomp2: (otherH / ((otherH+H)/2)) ** beta_H });
        }
        return data
    }

    const line1 = d3.line()
        .x(d => x(d.H))
        .y(d => y(d.Hcomp1));
        
    const line2 = d3.line()
        .x(d => x(d.H))
        .y(d => y(d.Hcomp2));

    const path1 = svg.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 2);
    
    const path2 = svg.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "red")
        .attr("stroke-width", 2);

    function updatePlot() {
        let beta_H = +d3.select("#beta_H").property("value");
        d3.select("#beta_H-value").text(beta_H);
        
        let data = calcData(beta_H);
        path1.datum(data).attr("d", line1);
        path2.datum(data).attr("d", line2);  
    }

    d3.selectAll(".light_competition_input").on("input", updatePlot);
    updatePlot();
}

function base_plot(id, axes_label, plot_margin, svg_size, ranges) {
    const plot_width = svg_size.width - plot_margin.left - plot_margin.right;
    const plot_height = svg_size.height - plot_margin.top - plot_margin.bottom;
    
    const svg = d3.select(`#${id}`)
        .attr("viewBox", `0 0 ${svg_size.width} ${svg_size.height}`)
        .attr("preserveAspectRatio", "xMidYMid meet");
    const plot = svg.append("g")
        .attr("transform", `translate(${plot_margin.left},${plot_margin.top})`);
        
    const x = d3.scaleLinear().domain([ranges.minx, ranges.maxx]).range([0, plot_width]);
    const y = d3.scaleLinear().domain([ranges.miny, ranges.maxy]).range([plot_height, 0]);
    const xAxis = d3.axisBottom(x);

    const yAxis = d3.axisLeft(y).ticks(3);
    plot.append("g")
        .call(yAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("transform", "rotate(-90)")
        .attr("fill", "#000")
        .attr("text-anchor", "middle")
        .selectAll("tspan")
        .data(axes_label.y.split("\n"))  
        .enter()
        .append("tspan")
        .attr("x", -plot_height / 2)
        .attr("y", -50)
        .attr("dy", (d, i) => -15 + i * 20)  
        .text(d => d);
    
    plot.append("g")
        .attr("transform", `translate(0,${plot_height})`)
        .call(xAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("x", plot_width / 2)
        .attr("y", 40)
        .attr("fill", "#000")
        .text(axes_label.x);
  
    return {plot: plot, x: x, y: y};
}

function lightIntercepted(actual_height, LAIs, γ_RUE_k) {
    let max_height = 1.55;
    let Δheightlayer = 0.05;
    let nspecies = 2;
    let nlayers = Math.ceil(max_height / Δheightlayer);
    
    let min_height_layer = Array.from({ length: nlayers }, (_, i) => i * Δheightlayer);
    let max_height_layer = Array.from({ length: nlayers }, (_, i) => (i + 1) * Δheightlayer);
    let LAIs_layer = Array.from({ length: nspecies }, () => Array(nlayers).fill(0));
    let LAItot_layer = Array(nlayers).fill(0);
    let cumLAItot_above = Array(nlayers).fill(0);
    let Intensity_layer = Array(nlayers).fill(0);
    let fPAR_layer = Array.from({ length: nspecies }, () => Array(nlayers).fill(0));
    
    
    // Calculate the LAI of each species in each layer
    for (let s = 0; s < nspecies; s++) {
        for (let l = 0; l < nlayers; l++) {
            if (min_height_layer[l] < actual_height[s] && actual_height[s] <= max_height_layer[l]) {
                let proportion_upper_layer = (actual_height[s] - min_height_layer[l]) / actual_height[s];
                let nlowerlayer = l;
                let proportion_lower_layer = (1 - proportion_upper_layer) / nlowerlayer;

                LAIs_layer[s][l] = proportion_upper_layer * LAIs[s];

                for (let n = 0; n < nlowerlayer; n++) {
                    LAIs_layer[s][n] = proportion_lower_layer * LAIs[s];
                }
            }
        }
    }

    // Calculate the total LAI in each layer
    for (let l = 0; l < nlayers; l++) {
        for (let s = 0; s < nspecies; s++) {
            LAItot_layer[l] += LAIs_layer[s][l];
        }
    }

    // Calculate the total LAI of all layers above each layer
    for (let l = 0; l < nlayers; l++) {
        for (let n = 0; n < nlayers; n++) {
            if (n > l) {
                cumLAItot_above[l] += LAItot_layer[n];
            }
        }
    }

    // Calculate the fraction of light that reaches each layer
    for (let l = 0; l < nlayers; l++) {
        Intensity_layer[l] = Math.exp(-γ_RUE_k * cumLAItot_above[l]);
    }

    // Calculate the fraction of light intercepted by each species in each layer
    for (let l = 0; l < nlayers; l++) {
        if (LAItot_layer[l] !== 0) {
            let fPAR = Intensity_layer[l] * (1 - Math.exp(-γ_RUE_k * LAItot_layer[l]));
            for (let s = 0; s < nspecies; s++) {
                fPAR_layer[s][l] = (LAIs_layer[s][l] / LAItot_layer[l]) * fPAR;
            }
        }
    }
    
    
    // Initialize LIG array with 0.0 for each species
    let LIG = Array(nspecies).fill(0.0);

    // Sum fPAR_layer values for each species across all layers
    for (let s = 0; s < nspecies; s++) {
        for (let l = 0; l < nlayers; l++) {
            LIG[s] += fPAR_layer[s][l];
        }
    }

    // Calculate community LIE
    let LAItot = 0;
    for (let s = 0; s < nspecies; s++) {
        LAItot += LAIs[s];
    }
    
    const comLIE = 1 - Math.exp(-γ_RUE_k * LAItot);

    // Divide LIG by comLIE to get the proportion for each species
    for (let s = 0; s < nspecies; s++) {
        LIG[s] /= comLIE;
    }

    return [LIG, fPAR_layer];
}


export function lightCompetitionHeightLayerPlot(){
    const marginBar = {top: 30, right: 30, bottom: 20, left: 120},
        width = 400 - marginBar.left - marginBar.right,
        height = 150 - marginBar.top - marginBar.bottom;
    
    const svgBar = d3.select("#totalIntercepted_graph")
        .attr("viewBox", `0 0 ${width + marginBar.left + marginBar.top} ${height + marginBar.top + marginBar.left}`)
        .attr("preserveAspectRatio", "xMidYMid meet")
        .append("g")
        .attr("transform", `translate(${marginBar.left}, ${marginBar.top})`);
    
    svgBar.append("text")
        .attr("x", (width / 2))             
        .attr("y", -5)
        .attr("text-anchor", "middle")  
        .text("Distribution of total growth among species [-]");
    
    const xBar = d3.scaleLinear([0, 1], [ 0, width]);
        svgBar.append("g")
        .attr("transform", `translate(0, ${height})`)
        .call(d3.axisBottom(xBar));

    
    const yBar = d3.scaleBand(["Species 1", "Species 2"], [0, height])
        .padding(0.1);
    svgBar.append("g")
        .call(d3.axisLeft(yBar))
    
    const bar1 = svgBar.append("rect")
        .attr("x", xBar(0.002))
        .attr("y", yBar("Species 1"))
        .attr("height", yBar.bandwidth())
        .attr("fill", "#69b3a2");
    
    const bar2 = svgBar.append("rect")
        .attr("x", xBar(0.002))
        .attr("y", yBar("Species 2"))
        .attr("height", yBar.bandwidth())
        .attr("fill", "orange");
        
    
    const svg_size = {width: 500, height: 200};
    const plot_margin = {top: 10, right: 20, bottom: 50, left: 90};
    const ranges = {minx: 0, maxx: 1.6, miny: 0, maxy: 0.2};
    const id = "height_layer_graph";
    const axes_label = {x: "Height [m]", 
                        y: "Proportion of\nlight intercepted [-]"}; 
    const {plot, x, y} = base_plot(id, axes_label, plot_margin, svg_size, ranges)
    
    const line = d3.line()
        .x(d => x(d.H))
        .y(d => y(d.INT));
        
    const path1 = plot.append("path")
        .attr("fill", "none")
        .attr("stroke", "#69b3a2")
        .attr("stroke-width", 1.5);
        
    const path2 = plot.append("path")
        .attr("fill", "none")
        .attr("stroke", "orange")
        .attr("stroke-width", 1.5);

    function updatePlot() {
        const LAI1 = +d3.select("#LAI1").property("value");
        const LAI2 = +d3.select("#LAI2").property("value");
        const H1 = +d3.select("#H1").property("value");
        const H2 = +d3.select("#H2").property("value");
        const γ_RUE_k = +d3.select("#γ_RUE_k").property("value");
        d3.select("#LAI1-value").text(LAI1);
        d3.select("#LAI2-value").text(LAI2);
        d3.select("#H1-value").text(H1);
        d3.select("#H2-value").text(H2);
        d3.select("#γ_RUE_k-value").text(γ_RUE_k);
        
        const [LIG, FPAR] = lightIntercepted([H1, H2], [LAI1, LAI2], γ_RUE_k);
        
        
        bar1.transition().duration(50)
            .attr("width", xBar(LIG[0]));
            
        bar2.transition().duration(50)
            .attr("width", xBar(LIG[1]));
        
        let max_height = 1.55;
        let Δheightlayer = 0.05;
        let nlayers = Math.ceil(max_height / Δheightlayer);
        let min_height_layer = Array.from({ length: nlayers }, (_, i) => i * Δheightlayer);
        let max_height_layer = Array.from({ length: nlayers }, (_, i) => (i + 1) * Δheightlayer);
        
    
        const data1 = [];
        const FPAR_species1 = FPAR[0]
        for (let l = 0; l < nlayers; l++) {
            data1.push({ H: min_height_layer[l], INT: FPAR_species1[l]});
            data1.push({ H: max_height_layer[l], INT: FPAR_species1[l]});
        }  
        path1.datum(data1)
            .transition()
            .duration(50)
            .attr("d", line);
            
            
        const data2 = [];
        const FPAR_species2 = FPAR[1]
        for (let l = 0; l < nlayers; l++) {
            data2.push({ H: min_height_layer[l], INT: FPAR_species2[l]});
            data2.push({ H: max_height_layer[l], INT: FPAR_species2[l]});
        }  
        path2.datum(data2)
            .transition()
            .duration(50)
            .attr("d", line);
    }
    
    updatePlot();
    d3.selectAll(".input_height_layer_graph").on("input", updatePlot);
}