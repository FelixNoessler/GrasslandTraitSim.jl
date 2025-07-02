import * as d3 from 'd3';
    
export function radiationReducerPlot() {
    const svg_width = 700, svg_height = 400;
    const margin = { top: 20, right: 110, bottom: 50, left: 70 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#radiation_reducer_graph")
        .attr("viewBox", `0 0 ${svg_width} ${svg_height}`)
        .attr("preserveAspectRatio", "xMidYMid meet")
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const max_x = 150000.0;
    const x = d3.scaleLinear().range([0, width]).domain([0, max_x]); 
    const y = d3.scaleLinear().range([height, 0]).domain([0, 1]); 

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
        .text("Photosynthetically active radiation (PAR) [MJ ha⁻¹]");

    svg.append("text")
        .attr("class", "y-label")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("transform", "rotate(-90)")
        .attr("text-anchor", "middle")
        .text("Growth reduction due to excess radiation (RAD)");

    function calcData(gamma1, gamma2) {
        const data = [];
        for (let PAR = 0; PAR <= max_x; PAR += max_x/200) {
            data.push({ 
                PAR: PAR, 
                RAD: Math.max(Math.min(1.0, 1.0 - gamma1 * (PAR - gamma2)), 0.0)
            })
        }
        return data
    }

    const line = d3.line()
        .x(d => x(d.PAR))
        .y(d => y(d.RAD));
        
    let data = calcData();

    const path = svg.append("path")
        .datum(data)
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 2)
        .attr("d", line);


    function updatePlot() {
        let gamma1 = +d3.select("#gamma1").property("value");
        let gamma2 = +d3.select("#gamma2").property("value");
        d3.select("#gamma1-value").text(gamma1);
        d3.select("#gamma2-value").text(gamma2);
        
        data = calcData(gamma1, gamma2);

        path.datum(data)
            .transition()
            .duration(0)
            .attr("d", line);
    }

    d3.selectAll(".radiation_reducer_input").on("input", updatePlot);
    updatePlot();
}