import * as d3 from 'd3';
    
export function seasonalAdjustmentPlot() {
    const svg_width = 700, svg_height = 400;
    const margin = { top: 20, right: 110, bottom: 50, left: 70 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#seasonal_adjustment_graph")
        .attr("viewBox", `0 0 ${svg_width} ${svg_height}`)
        .attr("preserveAspectRatio", "xMidYMid meet")
        .append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    const max_x = 3500.0;
    const max_y = 3.0;
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
        .text("Yearly accumulated air temperature (ST) [°C]");

    svg.append("text")
        .attr("class", "y-label")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("transform", "rotate(-90)")
        .attr("text-anchor", "middle")
        .text("Seasonal growth adjustment (SEA)");

    function calcData(ST1, ST2, SEA_min, SEA_max) {
        const data = [];
        for (let ST = 0; ST <= max_x; ST += max_x/200) {
            let SEA;
            if (ST < 200.0) {
                SEA = SEA_min;
            } else if (ST < ST1 - 200.0) {
                SEA = SEA_min + (SEA_max - SEA_min) * (ST - 200.0) / (ST1 - 400.0);
            } else if (ST < ST1 - 100.0) {
                SEA = SEA_max;
            } else if (ST < ST2) {
                SEA = SEA_min + (SEA_min - SEA_max) * (ST - ST2) / (ST2 - (ST1 - 100.0));
            } else {
                SEA = SEA_min;
            }
            
            data.push({ ST: ST, SEA: SEA });
        }
        return data
    }

    const line = d3.line()
        .x(d => x(d.ST))
        .y(d => y(d.SEA));
        
    let data = calcData();

    const path = svg.append("path")
        .datum(data)
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 2)
        .attr("d", line);

    function updatePlot() {
        let ST1 = +d3.select("#ST1").property("value");
        let ST2 = +d3.select("#ST2").property("value");
        let SEA_min = +d3.select("#SEA_min").property("value");
        let SEA_max = +d3.select("#SEA_max").property("value");
        d3.select("#ST1-value").text(ST1);
        d3.select("#ST2-value").text(ST2);
        d3.select("#SEA_min-value").text(SEA_min);
        d3.select("#SEA_max-value").text(SEA_max);
        
        data = calcData(ST1, ST2, SEA_min, SEA_max);

        path.datum(data)
            .transition()
            .duration(0)
            .attr("d", line);
    }

    d3.selectAll(".seasonal_adj_input").on("input", updatePlot);
    updatePlot();
}