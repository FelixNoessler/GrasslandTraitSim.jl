import * as d3 from 'd3';
    
export function temperatureReducerPlot() {
    const svg_width = 700, svg_height = 400;
    const margin = { top: 20, right: 110, bottom: 50, left: 70 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#temperature_reducer_graph")
        .attr("width", svg_width)
        .attr("height", svg_height)
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const max_x = 40.0;
    const x = d3.scaleLinear().range([0, width]).domain([0, max_x]); 
    const y = d3.scaleLinear().range([height, 0]).domain([-0.05, 1]); 

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
        .text("Mean air temperature (T) [°C]");

    svg.append("text")
        .attr("class", "y-label")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("transform", "rotate(-90)")
        .attr("text-anchor", "middle")
        .text("Growth reduction due to temperature (TEMP)");

    function calcData(T0, T1, T2, T3) {
        const data = [];
        for (let T = 0; T <= max_x; T += max_x/200) {
            let TEMP;

            if (T < T0) {
                TEMP = 0.0;
            } else if (T < T1) {
                TEMP = (T - T0) / (T1 - T0);
            } else if (T < T2) {
                TEMP = 1.0;
            } else if (T < T3) {
                TEMP = (T3 - T) / (T3 - T2);
            } else {
                TEMP = 0.0;
            }
            
            data.push({ T: T, TEMP: TEMP })
        }
        return data
    }

    const line = d3.line()
        .x(d => x(d.T))
        .y(d => y(d.TEMP));
        
    let data = calcData();

    const path = svg.append("path")
        .datum(data)
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 2)
        .attr("d", line);


    function updatePlot() {
        let T0 = +d3.select("#T0").property("value");
        let T1 = +d3.select("#T1").property("value");
        let T2 = +d3.select("#T2").property("value");
        let T3 = +d3.select("#T3").property("value");
        d3.select("#T0-value").text(T0);
        d3.select("#T1-value").text(T1);
        d3.select("#T2-value").text(T2);
        d3.select("#T3-value").text(T3);
        
        data = calcData(T0, T1, T2, T3);

        path.datum(data)
            .transition()
            .duration(0)
            .attr("d", line);
    }

    d3.selectAll(".temperature_reducer_input").on("input", updatePlot);
    updatePlot();
}