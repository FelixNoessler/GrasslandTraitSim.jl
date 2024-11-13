import * as d3 from 'd3';

export function potGrowthPlot() {
    const margin = {top: 15, right: 30, bottom: 45, left: 70},
        width = 600 - margin.left - margin.right,
        height = 400 - margin.top - margin.bottom;
    
    const svg = d3.select("#pot_growth_graph")
        .attr("viewBox", `0 0 ${width + margin.left + margin.top} ${height + margin.top + margin.left}`)
        .attr("preserveAspectRatio", "xMidYMid meet");

    const g = svg.append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const max_LAItot = 10;
    const x = d3.scaleLinear().range([0, width]).domain([0, max_LAItot]); 
    const y = d3.scaleLinear().range([height, 0]).domain([0, 1]); 

    // Create axes
    g.append("g")
        .attr("class", "x-axis")
        .attr("transform", `translate(0, ${height})`)
        .call(d3.axisBottom(x));

    g.append("g")
        .attr("class", "y-axis")
        .call(d3.axisLeft(y));

    // Axes labels
    g.append("text")
        .attr("class", "x-label")
        .attr("x", width / 2)
        .attr("y", height + 40)
        .attr("text-anchor", "middle")
        .text("Leaf area index of community (LAI_tot) [-]");

    g.append("text")
        .attr("class", "y-label")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("transform", "rotate(-90)")
        .attr("text-anchor", "middle")
        .text("Fraction of radiation intercepted (FPAR) [-]");

    function calcShading(){
        return Math.exp(Math.log(α_comH)*0.2 / H_cwm)
    }

    function calcInterception(LAItot){
        return (1 - Math.exp(-k * LAItot))
    }

    function calcData(height_influence) {
        const data = [];
        for (let LAItot = 0; LAItot <= max_LAItot; LAItot += 0.1) {
            if (height_influence) {
                data.push({ LAItot, fPAR: calcInterception(LAItot) * calcShading()});
            }else {
                data.push({ LAItot, fPAR: calcInterception(LAItot) });
            } 
        }
        return data
    }

    const line = d3.line()
        .x(d => x(d.LAItot))
        .y(d => y(d.fPAR));
        
    const line1 = d3.line()
        .x(d => x(d.LAItot))
        .y(d => y(d.fPAR));

    let k = 0.6, α_comH = 0.75, H_cwm = 0.7;

    let data1 = calcData(false);
    let data2 = calcData(true);

    const path = g.append("path")
        .datum(data1)
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 2)
        .attr("d", line);

    const path1 = g.append("path")
        .datum(data2)
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "red")
        .attr("stroke-width", 2)
        .attr("d", line1);

    // Update function
    function updatePlot() {
        k = +d3.select("#k").property("value");
        α_comH = +d3.select("#α_comH").property("value");
        H_cwm = +d3.select("#H_cwm").property("value");

        // Update slider labels
        d3.select("#k-value").text(k);
        d3.select("#α_comH-value").text(α_comH);
        d3.select("#H_cwm-value").text(H_cwm);

        // Recalculate data
        data1 = calcData(false);
        data2 = calcData(true);

        // Update line
        path.datum(data1)
            .transition()
            .duration(500)
            .attr("d", line);
            
        path1.datum(data2)
            .transition()
            .duration(500)
            .attr("d", line1);
    }

    // Event listeners for sliders
    d3.select("#k").on("input", updatePlot);
    d3.select("#α_comH").on("input", updatePlot);
    d3.select("#H_cwm").on("input", updatePlot);

    updatePlot();
}