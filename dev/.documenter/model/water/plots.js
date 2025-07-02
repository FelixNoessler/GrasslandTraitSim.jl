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

    const yAxis = d3.axisLeft(y);    
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
        .attr("y", -70)
        .attr("dy", (d, i) => i * 20)  
        .text(d => d);
    
    return {plot: plot, x: x, y: y};
}


export function WHCPWPPlot(){
    const svg_size = {width: 225, height: 400};
    const plot_margin = {top: 10, right: 0, bottom: 50, left: 150};
    const ranges = {minx: 0, maxx: 2, miny: 0, maxy: 500};
    const id = "whc_pwp_graph";
    const axes_label = {x: "", 
                        y: "Permanent wilting point (PWP, dark blue),\nwater holding capacity (WHC, bright blue) [mm]"}; 
    const {plot, x, y} = base_plot(id, axes_label, plot_margin, svg_size, ranges)

    const uFCLine = plot.append("line")
        .attr("x1", x(1)) 
        .attr("x2", x(1));
    
    const WHCCircle = plot.append("circle")
        .attr("r", 5)
        .attr("cx", x(1));
    
    const PWPCircle = plot.append("circle")
        .attr("r", 5)
        .attr("cx", x(1));
    
    function updatePlot() {
        const rootdepth = +d3.select("#rootdepth").property("value");
        const organic = +d3.select("#organic").property("value");
        const bulk = +d3.select("#bulk").property("value");
        const sand = +d3.select("#sand").property("value");
        const silt = +d3.select("#silt").property("value");

        d3.select("#rootdepth-value").text(rootdepth);
        d3.select("#organic-value").text(organic);
        d3.select("#bulk-value").text(bulk);
        d3.select("#sand-value").text(sand);
        d3.select("#silt-value").text(silt);
        
        const clay = 1 - sand - silt;
        d3.select("#clay-value").text(Math.round(clay * 100) / 100);
        
        const WHC = (0.5678 * sand + 
                    0.9228 * silt +
                    0.9135 * clay +
                    0.6103 * organic -
                    0.2696 * bulk) * rootdepth
        const PWP = (-0.0059 * sand +
                    0.1142 * silt +
                    0.5766 * clay +
                    0.2228 * organic +
                    0.02671 * bulk) * rootdepth
            
        if (sand + silt <= 1 && WHC > PWP) {
            WHCCircle.attr("fill", "SteelBlue").attr("cy", y(WHC));
            PWPCircle.attr("fill", "DarkBlue").attr("cy", y(PWP));    
            uFCLine.attr("stroke", "black")
                .attr("y1", y(PWP)) 
                .attr("y2", y(WHC));
                
        } else {
            uFCLine.attr("stroke", "white");  
            WHCCircle.attr("fill", "white");
            PWPCircle.attr("fill", "white");
        }
    }
    
    updatePlot();
    d3.selectAll(".input_whc_pwp_graph").on("input", updatePlot);
}