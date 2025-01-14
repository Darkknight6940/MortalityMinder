# Date: 2019/8/1
# Author: 
#   UI:Shengjin Li
#   Server: Yuxuan Wang
#   Graph: Ziyi Wang

source("Source.R")
library(shinyWidgets)
library(viridis)
library(plotly)
library(RUnit)
library(randomForest)
library(lubridate)
library(forcats)
library(htmltools)
deps <- list("topojson.min.js", 
             htmlDependency(name = "d3-scale-chromatic",
                            version = "1.3.3",
                            src = list(href = "https://d3js.org/"),
                            script = "d3-scale-chromatic.v1.min.js")
)
#-----------------
state.list <- state.abb
names(state.list) <- state.name

ui <- fluidPage(
  # include css
  tags$head(includeCSS("custom_no_scroll.css")),
  tags$head(includeCSS("jquery-ui.min.css")),
  tags$head(
    tags$script(src="jquery-3.4.1.min.js"),
    tags$script("$.noConflict(true);")),
  
  tags$div(
    class = "header",
    h6("WARNINGS")
  ),
  tags$div(
    class = "header_drop",
    h6("1. Smaller states (less than 4 counties) may have inaccurate result or result in errors."),
    h6("2. Some display issue of geo-graphs (legends may overlap with maps)."),
    h6("3. Suppressed number of death was substituted with 0.5 (will use other methods in future version)."),
    h6("4. Mortality rates are still part of socio-determinants used (which is not very useful)."),
    h6("5. Menu and get help not implemented.")
  ),
  
  # navbar
  tags$div(
    class = "navbar",
    tags$div(
      class = "title",
      h1("MortalityMinder")
    ),
    # tags$a(href="#page1","Mortality Overview"),
    # tags$a(href="#page2", "Social Determinants"),
    pickerInput(
      inputId = "state_choice",
      label = h4("State"), 
      choices = state.list,
      selected = "NY",
      width = "200px",
      options = list(
        `live-search` = TRUE,
        "dropup-auto" = FALSE
      )
    ),
    pickerInput(
      inputId = "death_cause",
      label = h4("Cause of Death"),
      choices = c("Despair","Cancer","Assault","Cardiovascular"),
      width = "200px",
      choicesOpt = list(
        subtext = c("Self-Harm and some other causes"),
        "dropup-auto" = FALSE
      )
    )
    
  ),
  
  tags$div(
    class = "main",
    # main
    tags$div(
      class = "mort_ana",
      
      tags$div(
        class = "col3",
        tags$div(
          class = "draggble",
          id = "first"
        ),
        tags$div(
          class = "draggble",
          id = "second"
          
        )
      ),
      
      tags$div(
        class = "col1",
        tags$div(
          class = "plot_col1",
          plotOutput("mort_line",width="100%",height="100%")
        ),
        tags$div(
          class = "text_col1",
          tags$div(
            class = "desc_head",
            h4("Mortality Trend")
          ),
          tags$div(
            class = "desc",
            tableOutput("table"),
            tags$p("This plot is generated with k-mean Clustering algorithm on the mortality trend."),
            tags$p("We first transform the data to a data frame with death rates of different counties
                   being the observations. "),
            tags$p("Each observation contains six periods
                   of death rates (2000-2002, 2003-2005 etc) of a specific county in the chosen state."),
            tags$p("These counites are then classified to 4 different clusters by k-mean."),
            tags$p("With the resultant clustering,
                   we calculate each cluster’s average death rates of a specific period and generate this line graph.")
            )
          
            )
        
        ),
      tags$div(
        class = "col2",
        tags$div(class = "vl"),
        tags$div(
          class = "col2_upper",
          tags$div(
            class = "col2_ul",
            plotOutput("geo_cluster_kmean",width="100%",height="100%")
            
          ),
          tags$div(
            class = "col2_um",
            plotOutput("geo_mort_change1",width="100%",height="100%")
          ),
          tags$div(
            class = "col2_ur",
            plotOutput("geo_mort_change2",width="100%",height="100%")

          )
        ),
        tags$div(
          class = "col2_lower",
          tags$hr(),
          plotOutput("page1.bar.cor1",width="100%",height="100%")
          
        )
        
      )
      
  ),
  tags$div(
    class = "sd",
    tags$div(
      class = "sd_col3"
      
    ),
    tags$div(
      class = "sd_col1",
      tags$div(class = "vl")
    ),
    tags$div(
      class = "sd_col2",
      tags$div(class = "vl"),
      tags$div(
        class = "desc_head",
        h4("Correlation")
      )
    )
  )
  
      ),
  
  tags$div(
    class = "helper",
    tags$h1("Help Options"),
    tags$hr(),
    tags$div(
      class = "helper_row",
      tags$h4("FAQ"),
      tags$i(class = "helper_arrow", tags$i(class="down_arrow"))
    ),
    tags$hr(),
    tags$div(
      class = "helper_row",
      tags$h4("Bugs"),
      tags$i(class = "helper_arrow", tags$i(class="down_arrow"))
    ),
    tags$hr(),
    tags$div(
      class = "helper_row",
      tags$h4("General Questions"),
      tags$i(class = "helper_arrow", tags$i(class="down_arrow"))
    )
  ),
  tags$div(
    class = "menu-background"
  ),
  tags$div(
    class = "menu-container",
    tags$div(
      class = "cross-container",
      tags$a(href="#", class="close")
    ),
    tags$div(
      class = "menu",
      tags$div(
        class = "menu_title",
        "Menu Page"
      ),
      tags$div(
        class = "menu_mort_overview"
      )
      
    )
  ),
  
  tags$div(
    class = "footer",
    tags$div(
      class = "logo",
      tags$img(src="RPIlogo.png", alt="IDEA",style="width:100%;height:100%;")
    ),
    tags$a(href="#", class="left", tags$i(class="left_arrow")),
    tags$a(href="#", class="menu_button", style="color:white;text-decoration: none;","menu"),
    tags$a(href="#", class="right", tags$i(class="right_arrow")),
    tags$a(href="#", class="helper_button", style="color:white;text-decoration: none;",
           tags$img(src="icons8-help-100.png", alt="help"),
           tags$p("Get Help")
    )
  ),
  
  
  
  tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/ScrollMagic/2.0.7/ScrollMagic.min.js"),
  tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/ScrollMagic/2.0.7/plugins/debug.addIndicators.min.js"),
  tags$script(src = "jquery-ui.min.js"),
  tags$script(src = "jquery.ba-outside-events.js"),
  includeScript(path = "myscript.js")
    )
#------------------

#-----------------

server <- function(input, output) {
  
  # Cache of UNORDERED mortality trend cluster label calculation
  mort.cluster.raw <- reactive({
    
    # Variables:
    #   - county_fips
    #   - cluster
    
    # Currently hard-coded 4 clusters
    cdc.data %>%
      cdc.mort.mat(input$state_choice, input$death_cause) %>%
      km.func(4)
  })
  
  # Cache of Weighed Avg by UNORDERED cluster
  mort.avg.cluster.raw <- reactive({
    
    # Variables:
    #   - period
    #   - cluster
    #   - death_rate
    #   - count
    
    # Notes:
    #   - The cluster labels are UNORDERED
    
    cdc.data %>%
      dplyr::filter(state_abbr == input$state_choice, death_cause == input$death_cause) %>%
      dplyr::right_join(mort.cluster.raw(), by = "county_fips") %>%
      dplyr::group_by(period, cluster) %>%
      dplyr::summarise(
        death_rate = sum(death_num) / sum(population) * 10^5,
        count = n()
      ) %>% 
      dplyr::ungroup()
  })
  
  # Cache of MAPPING from UNORDERED mortality trend label to ORDERED mortality trend label
  mort.cluster.map <- reactive({
    
    # Variables:
    #   - ord
  
    # Notes:
    #   - This is a mapping from raw cluster label to ORDERED cluster.
    #       Row names are the original cluster and `ord` are the reordered cluster
    
    mort.avg.cluster.raw() %>% 
      dplyr::filter(period == "2015-2017") %>%
      dplyr::arrange(death_rate) %>% 
      dplyr::mutate(ord = as.character(1:n())) %>% 
      dplyr::select(-c(period, death_rate)) %>% 
      textshape::column_to_rownames("cluster")
  })
  
  # Cache of ORDERED mortality trend cluster label calculation
  mort.cluster.ord <- reactive({
    
    # Variables:
    #   - county_fips
    #   - cluster

    dplyr::mutate(mort.cluster.raw(), cluster = mort.cluster.map()[cluster, "ord"])
  })
  
  # Cache of Weighed Avg by ORDERED cluster
  mort.avg.cluster.ord <- reactive({
    
    # Variables:
    #   - period
    #   - cluster
    #   - death_rate
    #   - count
    
    # Notes:
    #   - The cluster labels are ORDERED
    
    dplyr::mutate(mort.avg.cluster.raw(), cluster = mort.cluster.map()[cluster, "ord"])
  })

  # -------------------------------------------------------------------------------------------------------------------------- #
  
  # Mortality Rate Trend Line Graph
  output$mort_line <- renderPlot({
      ggplot(
        mort.avg.cluster.ord(),
        aes(
          x = period, y = death_rate, 
          color = cluster, group = cluster
        )
      ) + 
        geom_line(size = 1) + 
        geom_point(color = "black", shape = 21, fill = "white") + 
        labs.line.mort(input$state_choice, input$death_cause) + 
        color.line.cluster() +
        theme.line.mort() + 
        guides(
          color = guide_legend(reverse = T)
        )
  })
  
  # Mortality Rate Table
  output$table <- renderTable(width = "100%", {
    rate.table <- mort.avg.cluster.ord() %>%
      dplyr::select(cluster, period, death_rate) %>%
      tidyr::spread(key = period, value = death_rate) %>% 
      dplyr::select(cluster, `2000-2002`, `2015-2017`)
    
    count.table <- mort.avg.cluster.ord() %>% 
      dplyr::select(cluster, count) %>% 
      base::unique()
    
    dplyr::left_join(count.table, rate.table, by = "cluster") %>%
      dplyr::mutate(cluster = as.character(cluster)) %>%
      dplyr::arrange(desc(cluster)) %>%
      dplyr::rename(
        "Trend Grp." = "cluster",
        "Count" = "count"
      ) 
  })
  
  # Mortality Cluster Urbanization Composition
  output$urban_dist_cluster <- renderPlot({
    
    # Calculate cluster label
    cluster.num <- 4
    urban.data <- cdc.data %>% 
      dplyr::filter(state_abbr == input$state_choice) %>% 
      dplyr::select(county_fips, urban_2013) %>% 
      unique() %>% 
      dplyr::left_join(mort.label.raw(), by = "county_fips")
    
    ggplot(urban.data, aes(km_cluster, fill = urban_2013)) +
      geom_bar(position = "fill", color = "black", width = .75) +
      labs(
        title = "Urban-Rural Composition by Cluster",
        x = "Cluster",
        y = "Composition",
        fill = "Urbanization 2013"
      ) +
      scale_fill_manual(
        values = colorRampPalette(brewer.pal(9, "Blues"))(6)
      ) +
      theme_minimal() + 
      theme(
        plot.background = element_rect(fill = "gray95", color = "gray95"),
        plot.margin = unit(c(5, 10, 5, 10), units = "mm")
      ) + 
      theme.text() + 
      NULL
  })
  
  # Mortality Trend Cluster by County
  output$geo_cluster_kmean <- renderPlot({
    draw.geo.cluster(input$state_choice, mort.cluster.ord())
  })
  
  # Mortality Rate by County Period 1
  output$geo_mort_change1 <- renderPlot({

    mort.data <- dplyr::filter(
        cdc.data,
        state_abbr == input$state_choice,
        death_cause == input$death_cause,
        period == "2000-2002"
      ) %>%
      dplyr::mutate(
        death_rate = death_num / population * 10^5,
        death_rate = cut(death_rate, bin.geo.mort(input$death_cause))
      ) %>%
      dplyr::select(county_fips, death_rate, period)

    draw.geo.mort(input$state_choice, "2000-2002", mort.data, input$death_cause)
  })
  
  # Mortality Rate by County Period 2
  output$geo_mort_change2 <- renderPlot({
    
    mort.data <- dplyr::filter(
      cdc.data,
      state_abbr == input$state_choice,
      death_cause == input$death_cause,
      period == "2015-2017"
    ) %>% 
      dplyr::mutate(
        death_rate = death_num / population * 10^5,
        death_rate = cut(death_rate, bin.geo.mort(input$death_cause))
      ) %>%
      dplyr::select(county_fips, death_rate, period)
    
    draw.geo.mort(input$state_choice, "2015-2017", mort.data, input$death_cause)
  })
  
  # Kendall Correlation Between Raw Mort Rate and CHR-SD
  output$page1.bar.cor1 <- renderPlot({
    kendall.cor <- kendall.func(mort.cluster.ord(), chr.data.2019)
    
    kendall.cor %>%
      dplyr::mutate(
        Direction = dplyr::if_else(
          kendall_cor <= 0,
          "Protective",
          "Destructive"
        ),
        c("Protective"=#A5F00D ,"Destructive"=#0DF0BE )
        kendall_cor = abs(kendall_cor),
        chr_code = chr.namemap.2019[chr_code, 1]
      ) %>% na.omit() %>% 
      dplyr::filter(kendall_p < 0.05) %>% 
      dplyr::arrange(desc(kendall_cor)) %>% 
      dplyr::top_n(10, kendall_cor) %>%
      ggplot(
        aes(x = reorder(chr_code, kendall_cor), y = kendall_cor, color = Direction, fill = Direction)
      ) + 
      geom_point(stat = 'identity', size = 8) + 
      geom_segment(
        size = 1,
        aes(
          y = 0, 
          x = reorder(chr_code, kendall_cor), 
          yend = kendall_cor, 
          xend = reorder(chr_code, kendall_cor),
          color = Direction
        )
      ) +
      geom_text(
        aes(label = round(kendall_cor, 2)), 
        color = "black", 
        size = 2
      ) +
      coord_flip() + 
      scale_y_continuous(
        breaks = seq(
          round(min(kendall.cor$kendall_cor), 2) - .03,
          round(max(kendall.cor$kendall_cor), 2) + .03,
          by = .1
        )
      ) +
      geom_hline(yintercept = .0, linetype = "dashed") + 
      labs(
        title = "Most Influential Social Determinants of 2019",
        subtitle = "Kendall Correlation: SD - Mortality Trend Cluster",
        caption = "Data Source:\n\t1.CDCWONDER Multi-Cause of Death\n\t2.County Health Ranking 2019",
        y = "Correlation (tau)",
        x = NULL
      ) + 
      theme_minimal() +
      theme.text() + 
      theme.background() + 
      theme(
        axis.text.y = element_text(size = 12),
        axis.text.x = element_text(size = 12),
        axis.title.x = element_text(size = 12)
      )
    
  })
  
  
  data_to_json <- function(data) {
    jsonlite::toJSON(data, dataframe = "rows", auto_unbox = FALSE, rownames = TRUE)
  }
  output$d3 <- renderD3({
    data_geo <- jsonlite::read_json("all-counties.json")
    data_stat <- cdc.mort.mat(cdc.data,input$state_choice,input$death_cause)
    r2d3(data = list(data_geo,data_to_json(data_stat),state.name[grep(input$state_choice, state.abb)]),
         d3_version = 3,
         dependencies = "topojson.min.js",
         css = "geoattr.css",
         script = "d3.js")
  })
  
}

shinyApp(ui = ui, server = server)
