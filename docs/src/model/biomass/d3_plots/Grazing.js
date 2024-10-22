import * as d3 from 'd3';

export function grazingPlot() {
    const svg = d3.select("#grazing_graph"),
        margin = {top: 10, right: 30, bottom: 45, left: 60},
        width = +svg.attr("width") - margin.left - margin.right,
        height = +svg.attr("height") - margin.top - margin.bottom,
        g = svg.append("g").attr("transform", `translate(${margin.left},${margin.top})`);


    const x = d3.scaleLinear().range([0, width]).domain([0, 2000]); 
    const y = d3.scaleLinear().range([height, 0]).domain([0, 100]); 

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
        .text("Total aboveground biomass accessible to grazers [kg ha⁻¹]");

    g.append("text")
        .attr("class", "y-label")
        .attr("x", -height / 2)
        .attr("y", -40)
        .attr("transform", "rotate(-90)")
        .attr("text-anchor", "middle")
        .text("Total Grazed [kg ha⁻¹]");

    // Function to calculate total grazed based on η_GRZ, LD, and κ
    function calculateTotalGrazed(η_GRZ, LD, κ) {
        const biomassValues = d3.range(0, 5000, 10);
        
        return biomassValues.map(sum_biomass => {
            const biomass_exp = sum_biomass * sum_biomass;
            const α_GRZ = κ * LD * η_GRZ;
            const total_grazed = κ * LD * biomass_exp / (α_GRZ * α_GRZ + biomass_exp);

            return {sum_biomass, total_grazed};
        });
    }

    // function calculateTotalGrazed1(η_GRZ, LD, κ) {
    //     const biomassValues = d3.range(0, 5000, 10); 

    //     return biomassValues.map(sum_biomass => {
    //         const biomass_exp = sum_biomass * sum_biomass;
    //         const α_GRZ = κ * η_GRZ;
    //         const total_grazed = κ * LD * biomass_exp / (α_GRZ * α_GRZ + biomass_exp);

    //         return {sum_biomass, total_grazed};
    //     });
    // }

    const line = d3.line()
        .x(d => x(d.sum_biomass))
        .y(d => y(d.total_grazed));
    
    // const line1 = d3.line()
    //     .x(d => x(d.sum_biomass))
    //     .y(d => y(d.total_grazed));

    let η_GRZ = 1.0, LD = 2.0, κ = 22.0;
    let totalGrazedData = calculateTotalGrazed(η_GRZ, LD, κ);

    const path = g.append("path")
        .datum(totalGrazedData)
        .attr("class", "line")
        .attr("fill", "none")
        .attr("stroke", "steelblue")
        .attr("stroke-width", 2)
        .attr("d", line);

    // const path1 = g.append("path")
    //     .datum(totalGrazedData)
    //     .attr("class", "line")
    //     .attr("fill", "none")
    //     .attr("stroke", "steelblue")
    //     .attr("stroke-width", 2)
    //     .attr("d", line1);
    
    // Horizontal line at maximal consumption (κ * LD)
    const maxConsumptionLine = g.append("line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("y1", y(κ * LD))
        .attr("y2", y(κ * LD))
        .attr("stroke", "black")
        .attr("stroke-dasharray", "4,4");
    
    const halfConsumptionLine = g.append("line")
        .attr("x1", 0)
        .attr("x2", width)
        .attr("y1", y(κ * LD / 2))
        .attr("y2", y(κ * LD / 2))
        .attr("stroke", "grey")
        .attr("stroke-dasharray", "4,4");

    // Circle to represent the sum of biomass at half maximal consumption
    const halfConsumptionCircle = g.append("circle")
        .attr("r", 5)
        .attr("fill", "red")
        .attr("cx", x(κ * LD * η_GRZ))
        .attr("cy", y(κ * LD / 2));
    
    // const halfConsumptionCircle2 = g.append("circle")
    //     .attr("r", 5)
    //     .attr("fill", "orange")
    //     .attr("cx", x(κ * η_GRZ))
    //     .attr("cy", y(κ * LD / 2));

    // Update function
    function updatePlot() {
        η_GRZ = +d3.select("#η_GRZ").property("value");
        LD = +d3.select("#LD").property("value");
        κ = +d3.select("#κ").property("value");

        // Update slider labels
        d3.select("#η_GRZ-value").text(η_GRZ);
        d3.select("#LD-value").text(LD);
        d3.select("#κ-value").text(κ);

        // Recalculate data
        let totalGrazedData = calculateTotalGrazed(η_GRZ, LD, κ);
        // let totalGrazedData1 = calculateTotalGrazed1(η_GRZ, LD, κ);

        // Update line
        path.datum(totalGrazedData)
            .transition()
            .duration(500)
            .attr("d", line);
            
        // path1.datum(totalGrazedData1)
        //     .transition()
        //     .duration(500)
        //     .attr("d", line1);

        // Update horizontal line for maximal consumption (κ * LD)
        maxConsumptionLine
            .transition()
            .duration(50)
            .attr("y1", y(κ * LD))
            .attr("y2", y(κ * LD));
            
        halfConsumptionLine
            .transition()
            .duration(50)
            .attr("y1", y(κ * LD / 2))
            .attr("y2", y(κ * LD / 2));

        // Update circle for half maximal consumption
        halfConsumptionCircle
            .transition()
            .duration(50)
            .attr("cx", x(κ * LD * η_GRZ))
            .attr("cy", y(κ * LD / 2));
            
        // halfConsumptionCircle2
        //     .transition()
        //     .duration(500)
        //     .attr("cx", x(κ  * η_GRZ))
        //     .attr("cy", y(κ * LD / 2));
    }

    // Event listeners for sliders
    d3.select("#η_GRZ").on("input", updatePlot);
    d3.select("#LD").on("input", updatePlot);
    d3.select("#κ").on("input", updatePlot);

    updatePlot();
}
