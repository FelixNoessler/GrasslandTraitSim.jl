import * as d3 from 'd3';

export function plantAvailableWaterPlot() {
    const svg_width = 700, svg_height = 400;
    const margin = { top: 10, right: 110, bottom: 50, left: 70 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#plant_av_water_graph")
        .attr("width", svg_width)
        .attr("height", svg_height)
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const max_x = 200;
    const max_y = 1;
    const x = d3.scaleLinear().range([0, width]).domain([0, max_x]); 
    const y = d3.scaleLinear().range([height, 0]).domain([-0.02, max_y]); 

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
        .text("Soil water content in the rooting zone (W) [mm]");

    svg.append("text")
        .attr("class", "y-label")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("transform", "rotate(-90)")
        .attr("text-anchor", "middle")
        .text("Plant available water (Wₚ) [-]");
    
    function calcData(PWP, WHC) {
        const data = [];
        for (let W = 0; W <= max_x; W += max_x/200) {
            data.push({ 
                W: W, 
                Wp: Math.max(Math.min((W - PWP) / (WHC - PWP), 1.0), 0.0),
            });
        }
        return data
    }

    const line = d3.line()
        .x(d => x(d.W))
        .y(d => y(d.Wp));
        
    const path = svg.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 2);
    
    function updatePlot() {
        let PWP = +d3.select("#PWP").property("value");
        let WHC = +d3.select("#WHC").property("value");
        d3.select("#PWP-value").text(PWP);
        d3.select("#WHC-value").text(WHC);
        
        if (WHC > PWP) {
            let data = calcData(PWP, WHC);
            path.datum(data).attr("d", line);
        } else {
            path.datum([]).attr("d", line);
        }
    }

    d3.selectAll(".plant_av_water_input").on("input", updatePlot);
    updatePlot();
}


export function waterStressPlot() {
    // Initial parameters
    let β_R = 7, δ_R = 20, ϕ_trait = 0.15, ɑ_R_05 = 0.9;
    const trait_values = [0.05, 0.10, 0.15, 0.20, 0.25]; // rsa

    // Set up SVG dimensions
    const svg_width = 600, svg_height = 400;
    const margin = { top: 20, right: 110, bottom: 50, left: 75 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#water_stress_graph")
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
        .text("Plant available water (Wₚ) [-]");
    
    
    let ylabel = "Water growth reducer based on RSA (WAT) [-]\n← strong reduction, less reduction →"
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

    // Update parameters and plot
    function updateParameters() {
        β_R = +d3.select("#β_R").property("value");
        δ_R = +d3.select("#δ_R").property("value");
        ɑ_R_05 = +d3.select("#ɑ_R_05").property("value");
        ϕ_trait = +d3.select("#phi_RSA").property("value");

        d3.select("#β_R-value").text(β_R);
        d3.select("#δ_R-value").text(δ_R);
        d3.select("#ɑ_R_05-value").text(ɑ_R_05);
        d3.select("#phi_RSA-value").text(ϕ_trait);

        plot();
    }

    function calculateGrowthReduction(R, trait_values) {
        // const x0_R_05 = ϕ_trait + 1 / δ_R * Math.log((1 - ɑ_R_05) / ɑ_R_05);
        // const R_05 = 1 / (1 + Math.exp(-δ_R * (trait_values - x0_R_05)));
        // const x0 = Math.log((1 - R_05) / R_05) / β_R + 0.5;
        // return 1 / (1 + Math.exp(-β_R * (R - x0)));
        
        // alternative:
        const x0 = 1/β_R * (-δ_R * (trait_values - (1/δ_R * Math.log((1 - ɑ_R_05) / ɑ_R_05) + ϕ_trait))) + 0.5
        return 1 / (1 + Math.exp(-β_R * (R - x0)))
    }

    function plot() {
        svg.selectAll(".line").remove();
        svg.selectAll(".dot").remove();
        
        trait_values.forEach(trait => {
            const data = [];
            for (let R = 0; R <= 1; R += 0.01) {
                data.push({ R, Reducer: calculateGrowthReduction(R, trait) });
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
    plot();

    // Event listeners for sliders
    d3.selectAll(".input_water_stress_graph").on("input", updateParameters);  
}