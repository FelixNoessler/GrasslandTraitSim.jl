import * as d3 from 'd3';

function base_plot(id, axes_label, plot_margin, svg_size, ranges){
    const plot_width = svg_size.width - plot_margin.left - plot_margin.right;
    const plot_height = svg_size.height - plot_margin.top - plot_margin.bottom;
    
    const svg = d3.select(`#${id}`)
        .attr("viewBox", `0 0 ${svg_size.width} ${svg_size.height}`)
        .attr("preserveAspectRatio", "xMidYMid meet");
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
        .attr("x", -plot_height / 2)
        .attr("y", -40)
        .attr("fill", "#000")
        .attr("text-anchor", "middle")
        .text(axes_label.y);
        
    return {plot: plot, x: x, y: y};
}

export function seasonalSenescenceAjdPlot(){
    const svg_size = {width: 600, height: 400};
    const plot_margin = {top: 20, right: 20, bottom: 50, left: 70};
    const ranges = {minx: 0, maxx: 3500, miny: 0, maxy: 3.5};
    const id = "seasonal_senescence_graph";
    const axes_label = {x: "Cumulative temperature from the beginning of current year (ST) [°C] ", y: "Seasonal adjustment of senescence rate (SEN) [-]"}; 
    const {plot, x, y} = base_plot(id, axes_label, plot_margin, svg_size, ranges)
    
    const line1 = d3.line()
        .x(d => x(d.ST))
        .y(d => y(d.SENadj));
        
    const path1 = plot.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 1.5);
    
    function SENadj(ST, psi1, psi2, SENmax) {
        if (ST < psi1) {
            return 1;
        } else if (ST < psi2) {
            return 1 + (SENmax - 1) * (ST - psi1) / (psi2 - psi1);
        } else {
            return SENmax;
        }
    }
    
    function updatePlot() {
        const psi1 = d3.select("#psi1").property("value");
        const psi2 = d3.select("#psi2").property("value");
        const SENmax = d3.select("#SENmax").property("value");

        d3.select("#psi1-value").text(psi1);
        d3.select("#psi2-value").text(psi2);
        d3.select("#SENmax-value").text(SENmax);    
        
        const data = [];
        for (let ST = 0; ST <= ranges.maxx; ST += (ranges.maxx - ranges.minx) / 200) {
            data.push({ ST : ST, SENadj: SENadj(ST, psi1, psi2, SENmax) });
        }
        
        path1.datum(data).attr("d", line1);
    }

    updatePlot();

    d3.selectAll(".input_seasonal_senescence_graph").on("input", updatePlot);
}

export function SLASenescenceRatePlot(){
    const svg_size = {width: 600, height: 400};
    const plot_margin = {top: 20, right: 20, bottom: 50, left: 70};
    const ranges = {minx: 0.001, maxx: 0.02, miny: 0, maxy: 2.5};
    const id = "SLA_senescence_graph";
    const axes_label = {x: "Specific leaf area (sla) [m² g⁻¹] ", y: "Influence of the SLA on the senescence rate [-]"}; 
    const {plot, x, y} = base_plot(id, axes_label, plot_margin, svg_size, ranges)
    
    const line1 = d3.line()
        .x(d => x(d.SLA))
        .y(d => y(d.SLA_SENadj));
        
    const path1 = plot.append("path")
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 1.5);
    
    const phiSLACircle = plot.append("circle")
        .attr("cx", x(0.009))
        .attr("cy", y(1))
        .attr("r", 5)
        .attr("fill", "red");

    function updatePlot() {
        const phi_SLA = d3.select("#phi_SLA").property("value");
        const beta_SEN_SLA = d3.select("#beta_SEN_SLA").property("value");

        d3.select("#phi_SLA-value").text(phi_SLA);
        d3.select("#beta_SEN_SLA-value").text(beta_SEN_SLA);
        
        const data = [];
        for (let SLA = ranges.minx; SLA <= ranges.maxx; SLA += (ranges.maxx - ranges.minx) / 200) {
            data.push({ SLA : SLA, SLA_SENadj: (SLA / phi_SLA) ** beta_SEN_SLA });
        }
        
        phiSLACircle
            .transition()
            .duration(50)
            .attr("cx", x(phi_SLA));
        
        path1.datum(data)
            .transition()
            .duration(500)
            .attr("d", line1);
    }

    updatePlot();

    d3.selectAll(".input_SLA_senescence_graph").on("input", updatePlot);
}
