import * as d3 from 'd3';

export function rootCostsPlot(){
    let κ_maxred_amc = 0.2, ϕ_amc = 0.2;
    let xmax = 0.5;
    
    const svg_width = 700, svg_height = 400;
    const margin = { top: 25, right: 110, bottom: 50, left: 70 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#root_cost_graph")
        .attr("width", svg_width)
        .attr("height", svg_height)
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);
    
    const x = d3.scaleLinear().domain([0, xmax]).range([0, width]);
    const y = d3.scaleLinear().domain([0, 1.05]).range([height, 1.05]);
    
    
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
        .text("Belowground biomass proportion ⋅ Arbuscular mycorrhiza colonisation rate [-]");
    
    svg.append("g")
        .call(yAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("transform", "rotate(-90)")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("fill", "#000")
        .attr("text-anchor", "middle")
        .text("Growth reducer due to investment into mycorrhiza [-]");
    
    svg.append("line")
        .attr("x1", x(0)) 
        .attr("y1", y(1)) 
        .attr("x2", x(xmax)) 
        .attr("y2", y(1)) 
        .attr("stroke", "black") 
        .attr("stroke-dasharray", "5,5");
        
    const lowerLine = svg.append("line")
        .attr("x1", x(0)) 
        .attr("y1", y(1 - κ_maxred_amc)) 
        .attr("x2", x(xmax)) 
        .attr("y2", y(1 - κ_maxred_amc)) 
        .attr("stroke", "black") 
        .attr("stroke-dasharray", "5,5");
    
    const line = d3.line()
        .x(d => x(d.amc))
        .y(d => y(d.amc_invest));
        
    const path = svg.append("path")
        .datum(create_data())
        .attr("fill", "none")
        .attr("stroke", "black")
        .attr("stroke-width", 1.5)
        .attr("d", line);
            
    const halfCircle = svg.append("circle")
        .attr("cx", x(ϕ_amc))
        .attr("cy", y(1 - κ_maxred_amc / 2))
        .attr("r", 5)
        .attr("fill", "red");
            
    // Update parameters and plot
    function updateParameters() {
        κ_maxred_amc = +d3.select("#κ_maxred_amc").property("value");
        ϕ_amc = +d3.select("#ϕ_amc").property("value");
        d3.select("#κ_maxred_amc-value").text(κ_maxred_amc);
        d3.select("#ϕ_amc-value").text(ϕ_amc);
    
        plot();
    }
    
    function calc_amc_invest(amc) {
        return 1 - κ_maxred_amc + κ_maxred_amc * Math.exp(Math.log(0.5) / ϕ_amc * amc)   
    }
    
    function create_data() {
        const data = [];
        for (let amc = 0; amc <= xmax; amc += 0.002) {
            data.push({ amc, amc_invest: calc_amc_invest(amc) });
        }
        return data
    }
    
    function plot() {
        path.datum(create_data())
            .transition()
            .duration(500)
            .attr("d", line);
            
        halfCircle
            .transition()
            .duration(50)
            .attr("cx", x(ϕ_amc))
            .attr("cy", y(1 - κ_maxred_amc / 2));
            
        lowerLine
            .transition()
            .duration(50)
            .attr("y1", y(1 - κ_maxred_amc)) 
            .attr("y2", y(1 - κ_maxred_amc));
    }
    
    plot();
    
    d3.selectAll(".input_root_cost_graph").on("input", updateParameters);
}