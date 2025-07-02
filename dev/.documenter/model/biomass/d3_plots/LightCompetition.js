import * as d3 from 'd3';
    
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
    let LIG_layer = Array.from({ length: nspecies }, () => Array(nlayers).fill(0));
    
    
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
    
    
    // Calculate community LIE
    let LAItot = 0;
    for (let s = 0; s < nspecies; s++) {
        LAItot += LAIs[s];
    }
    const comLIE = 1 - Math.exp(-γ_RUE_k * LAItot);
        
    // Calculate the fraction of light intercepted by each species in each layer
    for (let l = 0; l < nlayers; l++) {
        if (LAItot_layer[l] !== 0) {
            const fPAR = Intensity_layer[l] * (1 - Math.exp(-γ_RUE_k * LAItot_layer[l]));
            for (let s = 0; s < nspecies; s++) {
                LIG_layer[s][l] = (LAIs_layer[s][l] / LAItot_layer[l]) * fPAR / comLIE;
            }
        }
    }
    
    // Initialize LIG array with 0.0 for each species
    let LIG = Array(nspecies).fill(0.0);

    // Sum LIG_layer values for each species across all layers
    for (let s = 0; s < nspecies; s++) {
        for (let l = 0; l < nlayers; l++) {
            LIG[s] += LIG_layer[s][l];
        }
    }

    return [LIG, LIG_layer];
}

export function lightCompetitionPlot() {
    const svg_width = 700, svg_height = 300;
    const margin = {top: 10, right: 110, bottom: 50, left: 70},
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#light_competition_graph")
        .attr("viewBox", `0 0 ${svg_width} ${svg_height}`)
        .attr("preserveAspectRatio", "xMidYMid meet")
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const max_x = 1.5;
    const max_y = 1.0;
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
        .text("Light competition factor (LIG) [-]");
    
    const line1 = d3.line()
        .x(d => x(d.H))
        .y(d => y(d.LIGlayer1));
        
    const line2 = d3.line()
        .x(d => x(d.H))
        .y(d => y(d.LIGlayer2));

    const path1 = svg.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "lightblue")
        .attr("stroke-width", 2);
    
    const path2 = svg.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "coral")
        .attr("stroke-width", 2);
        
        
    function updatePlot() {
        const LAI_1 = +d3.select("#LAI_1").property("value");
        const LAI_2 = +d3.select("#LAI_2").property("value");
        const H_2 = +d3.select("#H_2").property("value");
        const γ_RUE_k = +d3.select("#γRUEk").property("value");
        
        d3.select("#LAI_1-value").text(LAI_1);
        d3.select("#LAI_2-value").text(LAI_2);
        d3.select("#H_2-value").text(H_2);
        d3.select("#γRUEk-value").text(γ_RUE_k);
        
        const data = [];        
        for (let H_1 = 0; H_1 <= max_x; H_1 += max_x/200) {
            const [LIG, LIG_layers] = lightIntercepted([H_1, H_2], [LAI_1, LAI_2], γ_RUE_k);
            
            data.push({ 
                H: H_1, 
                LIGlayer1: LIG[0],
                LIGlayer2: LIG[1]});
        }
        
        path1.datum(data).transition()
            .duration(50)
            .attr("d", line1);
        path2.datum(data)
            .transition()
            .duration(50)
            .attr("d", line2);  
    }

    d3.selectAll(".light_competition_input").on("input", updatePlot);
    updatePlot();
}

export function HeightLayerPlot(){
    const svg_width = 600, svg_height = 300;
            
    const svg = d3.select("#height_layer_graph")
        .attr("viewBox", `0 0 ${svg_width} ${svg_height}`)
        .attr("preserveAspectRatio", "xMidYMid meet");
    
    const barplot_height = 100;
    const marginBar = {top: 20, right: 30, bottom: 30, left: 140},
        widthBar = svg_width - marginBar.left - marginBar.right,
        heightBar = barplot_height - marginBar.top - marginBar.bottom;    
    const gBar = svg.append("g")   
        .attr("transform", `translate(${marginBar.left}, ${marginBar.top})`);
     
    const marginPlot = {top: 10, right: 20, bottom: 50, left: 90},
        widthPlot = svg_width - marginPlot.left - marginPlot.right,
        heightPlot = svg_height - barplot_height - marginPlot.top - marginPlot.bottom;
    const gPlot = svg.append("g")
        .attr("transform", `translate(${marginPlot.left}, ${barplot_height + marginPlot.top})`);
    
 
    //  Bar plot
    gBar.append("text")
        .attr("x", (widthBar / 2))             
        .attr("y", -5)
        .attr("text-anchor", "middle")  
        .text("Distribution of total growth among species [-]");
    
    const xBar = d3.scaleLinear([0, 1], [ 0, widthBar]);
    gBar.append("g")
        .attr("transform", `translate(0, ${heightBar})`)
        .call(d3.axisBottom(xBar));

    const yBar = d3.scaleBand(["LIG - Species 1", "LIG - Species 2"], [0, heightBar])
        .padding(0.1);
    gBar.append("g")
        .call(d3.axisLeft(yBar))
    
    const bar1 = gBar.append("rect")
        .attr("x", xBar(0.002))
        .attr("y", yBar("LIG - Species 1"))
        .attr("height", yBar.bandwidth())
        .attr("fill", "lightblue");
    
    const bar2 = gBar.append("rect")
        .attr("x", xBar(0.002))
        .attr("y", yBar("LIG - Species 2"))
        .attr("height", yBar.bandwidth())
        .attr("fill", "coral");
        
    // Height layer plot
    const ranges = {minx: 0, maxx: 1.6, miny: 0, maxy: 0.2};
    const axes_label = {x: "Height [m]", 
                        y: "Light competition factor\nfor each layer (LIG_l) [-]"}; 
    
    const x = d3.scaleLinear().domain([ranges.minx, ranges.maxx]).range([0, widthPlot]);
    const y = d3.scaleLinear().domain([ranges.miny, ranges.maxy]).range([heightPlot, 0]);
    const xAxis = d3.axisBottom(x);

    const yAxis = d3.axisLeft(y).ticks(3);
    gPlot.append("g")
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
        .attr("x", -heightPlot / 2)
        .attr("y", -50)
        .attr("dy", (d, i) => -15 + i * 20)  
        .text(d => d);
    
    gPlot.append("g")
        .attr("transform", `translate(0,${heightPlot})`)
        .call(xAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("x", widthPlot / 2)
        .attr("y", 40)
        .attr("fill", "#000")
        .text(axes_label.x);
                            
                        
    const line = d3.line()
        .x(d => x(d.H))
        .y(d => y(d.INT));
        
    const path1 = gPlot.append("path")
        .attr("fill", "none")
        .attr("stroke", "lightblue")
        .attr("stroke-width", 1.5);
        
    const path2 = gPlot.append("path")
        .attr("fill", "none")
        .attr("stroke", "coral")
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
        const LIG_layer_species1 = FPAR[0]
        for (let l = 0; l < nlayers; l++) {
            data1.push({ H: min_height_layer[l], INT: LIG_layer_species1[l]});
            data1.push({ H: max_height_layer[l], INT: LIG_layer_species1[l]});
        }  
        path1.datum(data1)
            .transition()
            .duration(50)
            .attr("d", line);
            
            
        const data2 = [];
        const LIG_layer_species2 = FPAR[1]
        for (let l = 0; l < nlayers; l++) {
            data2.push({ H: min_height_layer[l], INT: LIG_layer_species2[l]});
            data2.push({ H: max_height_layer[l], INT: LIG_layer_species2[l]});
        }  
        path2.datum(data2)
            .transition()
            .duration(50)
            .attr("d", line);
    }
    
    updatePlot();
    d3.selectAll(".input_height_layer_graph").on("input", updatePlot);
}