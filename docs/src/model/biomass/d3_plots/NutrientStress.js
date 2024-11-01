import * as d3 from 'd3';

export function nutrientAdjustmentPlot(){
    let α_TSB = 10000, D_max = 4;
    let xmax = 40000;
     
    const margin = { top: 25, right: 60, bottom: 50, left: 70 },
        width = 600 - margin.left - margin.right,
        height = 400 - margin.top - margin.bottom;
    
    const svg = d3.select("#nutrient_adjustment_graph")
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);
    
    const x = d3.scaleLinear().domain([0, xmax]).range([0, width]);
    const y = d3.scaleLinear().domain([0, 10]).range([height, 0]);
    
    
    const xAxis = d3.axisBottom(x);
    const yAxis = d3.axisLeft(y);
    
    svg.append("g")
        .attr("transform", `translate(0,${height})`)
        .call(xAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("x", width / 2)
        .attr("y", 40)
        .attr("fill", "#000")
        .text("Total biomass scaled by trait similarity (∑ TS ⋅ B) [kg ⋅ ha⁻¹]");
    
    svg.append("g")
        .call(yAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("transform", "rotate(-90)")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("fill", "#000")
        .attr("text-anchor", "middle")
        .text("Nutrient adjustment factor (D) [-]");
    
    svg.append("line")
        .attr("x1", x(0)) 
        .attr("y1", y(1)) 
        .attr("x2", x(xmax)) 
        .attr("y2", y(1)) 
        .attr("stroke", "black") 
        .attr("stroke-dasharray", "5,5");
    
    const line = d3.line()
        .x(d => x(d.TS_B))
        .y(d => y(d.nut_adj));
        
    const path = svg.append("path")
        .datum(create_data())
        .attr("fill", "none")
        .attr("stroke", "black")
        .attr("stroke-width", 1.5)
        .attr("d", line);
    
    const maxCircle = svg.append("circle")
        .attr("cx", x(0))
        .attr("cy", y(D_max))
        .attr("r", 5)
        .attr("fill", "red");
            
    const oneCircle = svg.append("circle")
        .attr("cx", x(α_TSB))
        .attr("cy", y(1))
        .attr("r", 5)
        .attr("fill", "red");
            
    // Update parameters and plot
    function updateParameters() {
        α_TSB = +d3.select("#α_TSB").property("value");
        D_max = +d3.select("#D_max").property("value");
    
        d3.select("#α_TSB-value").text(α_TSB);
        d3.select("#D_max-value").text(D_max);
    
        plot();
    }
    
    function calculate_nutrient_adjustment(TS_B) {
        return D_max * Math.exp(Math.log(1/D_max) / α_TSB * TS_B)
    }
    
    function create_data() {
        const data = [];
        for (let TS_B = 0; TS_B <= xmax; TS_B += 100) {
            data.push({ TS_B, nut_adj: calculate_nutrient_adjustment(TS_B) });
        }
        return data
    }
    
    function plot() {
        path.datum(create_data())
            .transition()
            .duration(500)
            .attr("d", line);
        
        maxCircle
            .transition()
            .duration(50)
            .attr("cx", x(0))
            .attr("cy", y(D_max));
            
        oneCircle
            .transition()
            .duration(50)
            .attr("cx", x(α_TSB))
            .attr("cy", y(1));
    }
    
    plot();
    
    d3.selectAll(".nutrient_adjustment_graph_graph").on("input", updateParameters); 
}

export function nutrientStressRSAPlot(){
    const trait_values = [0.05, 0.10, 0.15, 0.20, 0.25]; // rsa

    const svg_width = 700, svg_height = 400;
    const margin = { top: 20, right: 110, bottom: 50, left: 75 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#nutrient_rsa_graph")
        .attr("width", svg_width)
        .attr("height", svg_height)
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const x = d3.scaleLinear().domain([0, 1]).range([0, width]);
    const y = d3.scaleLinear().domain([0, 1]).range([height, 0]);
    const color = d3.scaleSequential(d3.interpolateViridis).domain([0.05, 0.25]);

    const xAxis = d3.axisBottom(x);
    const yAxis = d3.axisLeft(y);

    svg.append("g")
        .attr("transform", `translate(0,${height})`)
        .call(xAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("x", width / 2)
        .attr("y", 40)
        .attr("fill", "#000")
        .text("Plant available nutrients (Nₚ) [-]");
    
    let ylabel = "Nutrient growth reducer based on RSA (NUT_rsa) [-]\n← strong reduction, less reduction →"
    svg.append("g")
        .call(yAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("transform", "rotate(-90)")
        .attr("fill", "#000")
        .attr("text-anchor", "middle")
        .selectAll("tspan")
        .data(ylabel.split("\n"))  
        .enter()
        .append("tspan")
        .attr("x", -height / 2)
        .attr("y", -60)
        .attr("dy", (d, i) => i * 20)  
        .text(d => d);
        
    const line = d3.line()
        .x(d => x(d.R))
        .y(d => y(d.Reducer));

    function calculateGrowthReduction(β_R, δ_R, ɑ_R_05, ϕ_trait, R, trait_values) {
        const x0_R_05 = ϕ_trait + 1 / δ_R * Math.log((1 - ɑ_R_05) / ɑ_R_05);
        const R_05 = 1 / (1 + Math.exp(-δ_R * (trait_values - x0_R_05)));
        const x0 = Math.log((1 - R_05) / R_05) / β_R + 0.5;
        return 1 / (1 + Math.exp(-β_R * (R - x0)));
    }

    function updatePlot() {
        let β_R = +d3.select("#β_RSA").property("value");
        let δ_R = +d3.select("#δ_RSA").property("value");
        let ɑ_R_05 = +d3.select("#ɑ_RSA_05").property("value");
        let ϕ_trait = +d3.select("#phi_RSA").property("value");

        d3.select("#β_RSA-value").text(β_R);
        d3.select("#δ_RSA-value").text(δ_R);
        d3.select("#ɑ_RSA_05-value").text(ɑ_R_05);
        d3.select("#phi_RSA-value").text(ϕ_trait);        
        
        svg.selectAll(".line").remove();
        svg.selectAll(".dot").remove();
        
        trait_values.forEach(trait => {
            const data = [];
            for (let R = 0; R <= 1; R += 0.01) {
                data.push({ R : R, Reducer: calculateGrowthReduction(β_R, δ_R, ɑ_R_05, ϕ_trait, R, trait) });
            }

            svg.append("path")
                .datum(data)
                .attr("class", "line")
                .attr("fill", "none")
                .attr("stroke", color(trait))
                .attr("stroke-width", 1.5)
                .attr("d", line);
        });
        
        svg.append("circle")
            .attr("class", "dot")
            .attr("cx", x(0.5))
            .attr("cy", y(ɑ_R_05))
            .attr("r", 3)
            .attr("fill", "red");
    }

    function createColorbar() {
        const colorbarHeight = 300;
        const colorbarWidth = 20;
        const colorScale = d3.scaleLinear()
            .domain([0, colorbarHeight])
            .range([0.05, 0.25]);

        if (svg.selectAll(".colorbar").empty()) {
            const defs = svg.append("defs");

            const linearGradient = defs.append("linearGradient")
                .attr("id", "linear-gradient")
                .attr("x1", "0%")
                .attr("y1", "100%")
                .attr("x2", "0%")
                .attr("y2", "0%");

            for (let i = 0; i <= colorbarHeight; i++) {
                linearGradient.append("stop")
                    .attr("offset", `${(i / colorbarHeight) * 100}%`)
                    .attr("stop-color", color(colorScale(i)));
            }

            svg.append("rect")
                .attr("x", width + 10)
                .attr("y", (height - colorbarHeight) / 2)
                .attr("width", colorbarWidth)
                .attr("height", colorbarHeight)
                .style("fill", "url(#linear-gradient)")
                .attr("class", "colorbar");

            const colorbarScale = d3.scaleLinear()
                .domain([0.05, 0.25])
                .range([(height - colorbarHeight) / 2 + colorbarHeight, (height - colorbarHeight) / 2]);

            const colorbarAxis = d3.axisRight(colorbarScale)
                .ticks(5)
                .tickFormat(d3.format(".3f"));

            svg.append("g")
                .attr("transform", `translate(${width + 10 + colorbarWidth}, 0)`)
                .attr("class", "colorbar-axis")
                .call(colorbarAxis);
                
            svg.append("text")
                .attr("x", width + 10 + colorbarWidth + 10)
                .attr("y", (height - colorbarHeight) / 2 + colorbarHeight / 3)
                .attr("fill", "#000")
                .text("Root surface area per total biomass (TRSA) [m² g⁻¹]")
                .attr("class", "colorbar-label")
                .attr("text-anchor", "middle")
                .attr("transform", `rotate(90, ${width + 10 + colorbarWidth + 10}, ${(height - colorbarHeight) / 2 + colorbarHeight / 2})`);
        }
    }

    createColorbar();
    updatePlot();

    d3.selectAll(".input_nutrient_rsa_graph").on("input", updatePlot);
}

export function nutrientStressAMCPlot(){
    const trait_values = [0.0, 0.10, 0.2, 0.30, 0.4]; // amc

    // Set up SVG dimensions
    const svg_width = 600, svg_height = 400;
    const margin = { top: 20, right: 110, bottom: 50, left: 75 },
          width = svg_width - margin.left - margin.right,
          height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#nutrient_amc_graph")
        .attr("width", svg_width)
        .attr("height", svg_height)
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const x = d3.scaleLinear().domain([0, 1]).range([0, width]);
    const y = d3.scaleLinear().domain([0, 1]).range([height, 0]);
    const color = d3.scaleSequential(d3.interpolateViridis).domain([0.0, 0.4]);

    const xAxis = d3.axisBottom(x);
    const yAxis = d3.axisLeft(y);

    svg.append("g")
        .attr("transform", `translate(0,${height})`)
        .call(xAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("x", width / 2)
        .attr("y", 40)
        .attr("fill", "#000")
        .text("Plant available nutrients (Nₚ) [-]");

    let ylabel = "Nutrient growth reducer based on AMC (NUT_amc) [-]\n← strong reduction, less reduction →"
    svg.append("g")
        .call(yAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("transform", "rotate(-90)")
        .attr("fill", "#000")
        .attr("text-anchor", "middle")
        .selectAll("tspan")
        .data(ylabel.split("\n"))  
        .enter()
        .append("tspan")
        .attr("x", -height / 2)
        .attr("y", -60)
        .attr("dy", (d, i) => i * 20)  
        .text(d => d);
            
    const line = d3.line()
        .x(d => x(d.R))
        .y(d => y(d.Reducer));

    function calculateGrowthReduction(β_R, δ_R, ɑ_R_05, ϕ_trait, R, trait_values) {
        const x0_R_05 = ϕ_trait + 1 / δ_R * Math.log((1 - ɑ_R_05) / ɑ_R_05);
        const R_05 = 1 / (1 + Math.exp(-δ_R * (trait_values - x0_R_05)));
        const x0 = Math.log((1 - R_05) / R_05) / β_R + 0.5;
        return 1 / (1 + Math.exp(-β_R * (R - x0)));
    }

    function updatePlot() {
        let β_R = +d3.select("#β_AMC").property("value");
        let δ_R = +d3.select("#δ_AMC").property("value");
        let ɑ_R_05 = +d3.select("#ɑ_AMC_05").property("value");
        let ϕ_trait = +d3.select("#phi_AMC").property("value");

        d3.select("#β_AMC-value").text(β_R);
        d3.select("#δ_AMC-value").text(δ_R);
        d3.select("#ɑ_AMC_05-value").text(ɑ_R_05);
        d3.select("#phi_AMC-value").text(ϕ_trait);

        svg.selectAll(".line").remove();
        svg.selectAll(".dot").remove();
        
        trait_values.forEach(trait => {
            const data = [];
            for (let R = 0; R <= 1; R += 0.01) {
                data.push({ R, Reducer: calculateGrowthReduction(β_R, δ_R, ɑ_R_05, ϕ_trait, R, trait) });
            }

            svg.append("path")
                .datum(data)
                .attr("class", "line")
                .attr("fill", "none")
                .attr("stroke", color(trait))
                .attr("stroke-width", 1.5)
                .attr("d", line);
        });
        
        svg.append("circle")
            .attr("class", "dot")
            .attr("cx", x(0.5))
            .attr("cy", y(ɑ_R_05))
            .attr("r", 3)
            .attr("fill", "red");
    }

    function createColorbar() {
        const colorbarHeight = 300;
        const colorbarWidth = 20;
        const colorScale = d3.scaleLinear()
            .domain([0, colorbarHeight])
            .range([0.0, 0.4]);

        if (svg.selectAll(".colorbar").empty()) {
            const defs = svg.append("defs");

            const linearGradient = defs.append("linearGradient")
                .attr("id", "linear-gradient")
                .attr("x1", "0%")
                .attr("y1", "100%")
                .attr("x2", "0%")
                .attr("y2", "0%");

            for (let i = 0; i <= colorbarHeight; i++) {
                linearGradient.append("stop")
                    .attr("offset", `${(i / colorbarHeight) * 100}%`)
                    .attr("stop-color", color(colorScale(i)));
            }

            svg.append("rect")
                .attr("x", width + 10)
                .attr("y", (height - colorbarHeight) / 2)
                .attr("width", colorbarWidth)
                .attr("height", colorbarHeight)
                .style("fill", "url(#linear-gradient)")
                .attr("class", "colorbar");

            const colorbarScale = d3.scaleLinear()
                .domain([0.0, 0.4])
                .range([(height - colorbarHeight) / 2 + colorbarHeight, (height - colorbarHeight) / 2]);

            const colorbarAxis = d3.axisRight(colorbarScale)
                .ticks(5)
                .tickFormat(d3.format(".3f"));

            svg.append("g")
                .attr("transform", `translate(${width + 10 + colorbarWidth}, 0)`)
                .attr("class", "colorbar-axis")
                .call(colorbarAxis);
                
            const textData = ["Arbuscular mycorrhizal", "colonisation per total biomass (TAMC) [m² g⁻¹]"];
            const centerX = width + 10 + colorbarWidth + 60;
            const centerY = (height - colorbarHeight) / 2 + colorbarHeight / 2;    
            svg.append("text")   
                .attr("x", centerX)
                .attr("y", centerY) 
                .attr("text-anchor", "middle")
                .attr("font-size", "16px")
                .attr("transform", `rotate(90, ${centerX}, ${centerY})`)  // Rotate around the center
                .selectAll("tspan")
                .data(textData)
                .enter()
                .append("tspan")
                .attr("x", centerX)
                .attr("dy", (d, i) => i * 25 - ((textData.length - 1) * 10))  // Adjust dy to center the lines
                .text(d => d);
        }
    }

    createColorbar();
    updatePlot();

    d3.selectAll(".input_nutrient_amc_graph").on("input", updatePlot);   
}
