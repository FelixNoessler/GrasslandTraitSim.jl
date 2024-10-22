import * as d3 from 'd3';
    
export function lightCompetitionPlot() {
    const svg_width = 700, svg_height = 400;
    const margin = { top: 0, right: 110, bottom: 50, left: 70 },
        width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;

    const svg = d3.select("#light_competition_graph")
        .attr("width", svg_width)
        .attr("height", svg_height)
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