import * as d3 from 'd3';

function base_plot(id, axes_label, plot_margin, svg_size, ranges){
    const plot_width = svg_size.width - plot_margin.left - plot_margin.right;
    const plot_height = svg_size.height - plot_margin.top - plot_margin.bottom;
    
    const svg = d3.select(`#${id}`)
        .attr("width", svg_size.width)
        .attr("height", svg_size.height);
    const plot = svg.append("g")
        .attr("transform", `translate(${plot_margin.left},${plot_margin.top})`);
        
    const x = d3.scaleLinear().domain([ranges.minx, ranges.maxx]).range([0, plot_width]);
    const y = d3.scaleLinear().domain([ranges.miny, ranges.maxy]).range([plot_height, 0]);
    const xAxis = d3.axisBottom(x);
    const yAxis = d3.axisLeft(y);
    
    plot.append("g")
        .attr("transform", `translate(0,${plot_height})`)
        .call(xAxis)
        .append("text")
        .attr("class", "axis-label")
        .attr("x", plot_width / 2)
        .attr("y", 40)
        .attr("fill", "#000")
        .text(axes_label.x);
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
        .attr("y", -60)
        .attr("dy", (d, i) => i * 20)  
        .text(d => d);
    
    return {plot: plot, x: x, y: y};
}


export function RSACostsPlot(){
    const svg_size = {width: 600, height: 400};
    const plot_margin = {top: 20, right: 20, bottom: 50, left: 70};
    const ranges = {minx: 0, maxx: 0.25, miny: 0, maxy: 1.05};
    const id = "rsa_cost_graph";
    const axes_label = {x: "Root surface area per total biomass (TRSA) [m² g⁻¹]", 
                        y: "Growth reduction due to investment\nin root surface area (ROOT_RSA) [-]"}; 
    const {plot, x, y} = base_plot(id, axes_label, plot_margin, svg_size, ranges)

    plot.append("line")
        .attr("x1", x(0)) 
        .attr("y1", y(1)) 
        .attr("x2", x(ranges.maxx)) 
        .attr("y2", y(1)) 
        .attr("stroke", "black") 
        .attr("stroke-dasharray", "5,5");
        
    const lowerLine = plot.append("line")
        .attr("x1", x(0)) 
        .attr("x2", x(ranges.maxx)) 
        .attr("stroke", "black") 
        .attr("stroke-dasharray", "5,5");
    
    const line = d3.line()
        .x(d => x(d.rsa))
        .y(d => y(d.rsa_invest));
        
    const path = plot.append("path")
        .attr("fill", "none")
        .attr("stroke", "black")
        .attr("stroke-width", 1.5);
            
    const halfCircle = plot.append("circle")
        .attr("r", 5)
        .attr("fill", "red");

    function updatePlot() {
        const κ_rsa = d3.select("#κ_rsa").property("value");
        const ϕ_TRSA = d3.select("#ϕ_TRSA").property("value");
        d3.select("#κ_rsa-value").text(κ_rsa);
        d3.select("#ϕ_TRSA-value").text(ϕ_TRSA);
        
        const data = [];
        for (let rsa = ranges.minx; rsa <= ranges.maxx; rsa += (ranges.maxx - ranges.minx) / 200) {
            data.push({ 
                rsa: rsa, 
                rsa_invest: 1 - κ_rsa + κ_rsa * Math.exp(Math.log(0.5) / ϕ_TRSA * rsa) 
            });
        }

        path.datum(data)
            .transition()
            .duration(500)
            .attr("d", line);
        
        halfCircle
            .transition()
            .duration(50)
            .attr("cx", x(ϕ_TRSA))
            .attr("cy", y(1 - κ_rsa / 2));
            
        lowerLine
            .transition()
            .duration(50)
            .attr("y1", y(1 - κ_rsa)) 
            .attr("y2", y(1 - κ_rsa));
    }
    
    updatePlot();
    d3.selectAll(".input_rsa_cost_graph").on("input", updatePlot);
}

export function AMCCostsPlot(){
    const svg_size = {width: 600, height: 400};
    const plot_margin = {top: 20, right: 20, bottom: 50, left: 70};
    const ranges = {minx: 0, maxx: 0.5, miny: 0, maxy: 1.05};
    const id = "amc_cost_graph";
    const axes_label = {x: "Arbuscular mycorrhiza colonisation rate per total biomass (TAMC) [-]", 
                        y: "Growth reduction due to investment\nin mycorrhiza (ROOT_AMC) [-]"}; 
    const {plot, x, y} = base_plot(id, axes_label, plot_margin, svg_size, ranges)

    plot.append("line")
        .attr("x1", x(0)) 
        .attr("y1", y(1)) 
        .attr("x2", x(ranges.maxx)) 
        .attr("y2", y(1)) 
        .attr("stroke", "black") 
        .attr("stroke-dasharray", "5,5");
        
    const lowerLine = plot.append("line")
        .attr("x1", x(0)) 
        .attr("x2", x(ranges.maxx)) 
        .attr("stroke", "black") 
        .attr("stroke-dasharray", "5,5");
    
    const line = d3.line()
        .x(d => x(d.amc))
        .y(d => y(d.amc_invest));
        
    const path = plot.append("path")
        .attr("fill", "none")
        .attr("stroke", "black")
        .attr("stroke-width", 1.5);
            
    const halfCircle = plot.append("circle")
        .attr("r", 5)
        .attr("fill", "red");

    function updatePlot() {
        const κ_amc = d3.select("#κ_amc").property("value");
        const ϕ_TAMC = d3.select("#ϕ_TAMC").property("value");
        d3.select("#κ_amc-value").text(κ_amc);
        d3.select("#ϕ_TAMC-value").text(ϕ_TAMC);
        
        const data = [];
        for (let amc = ranges.minx; amc <= ranges.maxx; amc += (ranges.maxx - ranges.minx) / 200) {
            data.push({ 
                amc: amc, 
                amc_invest: 1 - κ_amc + κ_amc * Math.exp(Math.log(0.5) / ϕ_TAMC * amc) 
            });
        }

        path.datum(data)
            .transition()
            .duration(500)
            .attr("d", line);
        
        halfCircle
            .transition()
            .duration(50)
            .attr("cx", x(ϕ_TAMC))
            .attr("cy", y(1 - κ_amc / 2));
            
        lowerLine
            .transition()
            .duration(50)
            .attr("y1", y(1 - κ_amc)) 
            .attr("y2", y(1 - κ_amc));
    }
    
    updatePlot();
    d3.selectAll(".input_amc_cost_graph").on("input", updatePlot);
}