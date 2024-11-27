library(readxl)
library(httr)
library(rvest)
library(dplyr)
library(stringr)

# Read the search data from the Excel file
search_path <- 'search_data.xlsx'
search_data <- read_excel(search_path)


# Function to parse the case text and extract details
parse_case <- function(case_text, search_key) {
    processo <- str_extract(case_text, "\\d{7}-\\d{2}\\.\\d{4}\\.\\d\\.\\d{2}\\.\\d{4}")
    classe <- str_extract(case_text, "(?<=Classe:\\s)[^\\n]+")
    assunto <- str_extract(case_text, "(?<=Assunto:\\s)[^\\n]+")
    magistrado <- str_extract(case_text, "(?<=Magistrado:\\s)[^\\n]+")
    comarca <- str_extract(case_text, "(?<=Comarca:\\s)[^\\n]+")
    foro <- str_extract(case_text, "(?<=Foro:\\s)[^\\n]+")
    vara <- str_extract(case_text, "(?<=Vara:\\s)[^\\n]+")
    data_disponibilizacao <- str_extract(case_text, "(?<=Data de Disponibilização:\\s)[^\\n]+")
    # Extract Decision text
    decision_text <- str_split(case_text, "Data de Disponibilização:\\s[^\\n]+\\n")[[1]][2]
    if (!is.na(decision_text)) {
      decision <- str_split(decision_text, "IMPRESSÃO À MARGEM DIREITA")[[1]][1]
      # Clean up \n, \t, and extra spaces
      decision <- str_replace_all(decision, "\\s+", " ")
      decision <- str_trim(decision)
    } else {
          decision <- NA
    }
  
    data.frame(
        Pesquisa_Livre = search_key,
        Processo = processo,
        Classe = classe,
        Assunto = assunto,
        Magistrado = magistrado,
        Comarca = comarca,
        Foro = foro,
        Vara = vara,
        Data_Disponibilizacao = data_disponibilizacao,
        Decision = decision,
        stringsAsFactors = FALSE
    )
}

    # List to store all results
    results_list <- list()

    # Loop through the search data
    for (i in seq_len(nrow(search_data))) {
    # Print progress for each iteration
    cat("Processing row:", i, "\n")
    if (search_data$Varas[i] == 'Foro Regional II - Santo Amaro'){
        new_varas <- '122 Registros selecionados'
        varas_value <- '2-2723,2-6843,2-997,2-203,2-6874,2-7386,2-3772,2-9,2-2894,2-501,2-2,2-5221,2-3820,2-6873,2-998,2-3127,2-6844,2-3710,2-1001,2-103,2-6875,2-7385,2-3534,2-204,2-2602,2-6865,2-502,2-5490,2-3979,2-8,2-5689,2-6350,2-7387,2-7388,2-102,2-5610,2-5717,2-6845,2-999,2-13,2-6872,2-6841,2-321,2-4,2-5442,2-6883,2-3868,2-202,2-5757,2-2005,2-4864,2-2003,2-5569,2-3026,2-601,2-6881,2-6890,2-3469,2-5323,2-15,2-6870,2-11,2-6888,2-1848,2-2004,2-6878,2-5742,2-604,2-603,2-3389,2-4367,2-5099,2-1673,2-901,2-5633,2-101,2-6312,2-7221,2-505,2-4684,2-6889,2-6879,2-10,2-3589,2-6867,2-6866,2-5,2-5649,2-6,2-7,2-6868,2-504,2-6876,2-503,2-6887,2-4499,2-201,2-3634,2-205,2-3853,2-6886,2-602,2-3952,2-3199,2-3,2-6869,2-506,2-6862,2-2109,2-900,2-12,2-5528,2-3676,2-14,2-1900,2-6840,2-6871,2-1,2-3280,2-703,2-3910,2-1697'
    }
    if (search_data$Varas[i] == 'Foro Regional VI - Penha de França'){
        new_varas <- '53 Registros selecionados'
        varas_value <- '6-2598,6-6845,6-999,6-4,6-502,6-6865,6-503,6-2012,6-4861,6-601,6-3,6-602,6-4495,6-900,6-2,6-5438,6-3276,6-1844,6-6867,6-3797,6-5095,6-3715,6-6347,6-2009,6-2011,6-998,6-3825,6-201,6-321,6-5912,6-2105,6-101,6-202,6-3123,6-2720,6-704,6-3924,6-6863,6-5674,6-1,6-5050,6-997,6-2008,6-4415,6-4681,6-501,6-2010,6-3776,6-6846,6-3680,6-6868,6-2890,6-5218'
    }
    if (search_data$Varas[i] == 'Foro Regional VII - Itaquera'){
        new_varas <- '60 Registros selecionados'
        varas_value <- '7-2,7-997,7-998,7-104,7-601,7-1,7-3,7-6863,7-502,7-1897,7-202,7-203,7-4848,7-501,7-6862,7-602,7-1843,7-201,7-103,7-2103,7-3385,7-5487,7-3466,7-2597,7-3681,7-3886,7-6850,7-6344,7-3777,7-6848,7-6870,7-6847,7-2888,7-6871,7-5,7-6851,7-504,7-5215,7-101,7-1000,7-3913,7-603,7-3121,7-5522,7-4,7-4492,7-102,7-6852,7-503,7-6846,7-999,7-3826,7-5312,7-3798,7-3716,7-5092,7-5435,7-4678,7-321,7-6306'
    }
    if (search_data$Varas[i] == 'Foro Regional VIII - Tatuapé'){
        new_varas <- '59 Registros selecionados'
        varas_value <- '8-202,8-3827,8-3682,8-2900,8-4500,8-5100,8-6849,8-203,8-7224,8-997,8-3472,8-7223,8-7,8-998,8-3,8-501,8-1852,8-4847,8-201,8-4865,8-602,8-6851,8-5311,8-3799,8-3284,8-1,8-7390,8-3717,8-5611,8-2606,8-5324,8-4,8-5,8-4685,8-5443,8-6847,8-5521,8-999,8-6313,8-502,8-5648,8-6,8-503,8-6351,8-7337,8-204,8-2724,8-101,8-3133,8-2115,8-5222,8-2,8-5690,8-321,8-3693,8-6850,8-601,8-3778,8-1903'
    }
    if (search_data$Varas[i] == 'Foro Regional XII - Nossa Senhora do Ó'){
        new_varas <- '28 Registros selecionados'
        varas_value <- '20-5,20-1,20-2,20-3,20-4,20-5223,20-4851,20-201,20-222,20-203,20-6321,20-2889,20-4502,20-216,20-3122,20-214,20-218,20-4686,20-215,20-213,20-5102,20-217,20-219,20-6319,20-2104,20-202,20-6315,20-7228'
    }

    search_key <- search_data$Pesquisa_Livre[i]
    
    # Construct the URL for the current row's search data
        base_url <- "https://esaj.tjsp.jus.br/cjpg/pesquisar.do?"
        date = format(Sys.Date(), "%d/%m/%Y")

        url <- paste0(
            base_url,'conversationId=&dadosConsulta.pesquisaLivre=', URLencode(search_data$Pesquisa_Livre[i]), 
            '&tipoNumero=UNIFICADO&numeroDigitoAnoUnificado=&foroNumeroUnificado=&dadosConsulta.nuProcesso=&dadosConsulta.nuProcessoAntigo=&classeTreeSelection.values=&classeTreeSelection.text=&assuntoTreeSelection.values=10467&assuntoTreeSelection.text=',
            URLencode(search_data$Assunto[i]), '&agenteSelectedEntitiesList=&contadoragente=0&contadorMaioragente=0&cdAgente=&nmAgente=&dadosConsulta.dtInicio=&dadosConsulta.dtFim=',
            URLencode(date), '&varasTreeSelection.values=', URLencode(varas_value), '&varasTreeSelection.text=',
            URLencode(new_varas), '&dadosConsulta.ordenacao=DESC'
        )

    # Set user agent for the HTTP request
    user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    
    # Send GET request and handle potential errors
    response <- GET(url, add_headers(`User-Agent` = user_agent))
    if (status_code(response) != 200) {
        cat("Failed to retrieve page for", search_data$Pesquisa_Livre[i], "\n")
        next
    }
    
    # Parse the HTML content
    html_content <- content(response, as = "text", encoding = "UTF-8")
    page <- read_html(html_content)
    
    # Extract results
    results <- page %>% html_node("td#tdResultados") %>% html_text(trim = TRUE)

    # Sample text data
    text_data <- paste(results, collapse = "\n")
    
    # Split cases and parse each case
    cases <- str_split(text_data, "(?=TRIBUNAL DE JUSTIÇA DO ESTADO DE SÃO PAULO)")[[1]]

    case_data_list <- list()

    for (case in cases) {
        case_data <- parse_case(case, search_key)
        case_data_list <- append(case_data_list, list(case_data))
    }
    # Append the parsed case data to the results list
    results_list <- do.call(rbind, case_data_list)
    results_list$Processo <- c(results_list$Processo[-1], NA)
    results_list <- results_list[!is.na(results_list$Processo), ]
    if(i == 1){
        write.csv(results_list, 'result.csv', row.names = FALSE)
    }
    else{
        write.table(results_list, 'result.csv',append = TRUE, row.names = FALSE, col.names = FALSE, sep = ',')
    }

    cnt <- 1

    while(1) {
        strong_tags <- page %>% html_nodes('strong')
        numbers_text <- strong_tags[1] %>% html_text(trim = TRUE)
        numbers <- str_extract_all(numbers_text, '\\d+')
        numbers <- unlist(numbers)
        
        if(length(numbers) > 1){
            print(length(numbers))
            start <- as.integer(numbers[1])
            end <- as.integer(numbers[2])
            isNext <- end-start
            
            if (isNext == 9) {
                cnt <- cnt + 1
                base_url2 <- "https://esaj.tjsp.jus.br/cjpg/trocarDePagina.do?"
                url2 <- paste0(
                    base_url2,'pagina=', cnt, '&conversationId=&dadosConsulta.pesquisaLivre=', URLencode(search_data$Pesquisa_Livre[i]), 
                    '&tipoNumero=UNIFICADO&numeroDigitoAnoUnificado=&foroNumeroUnificado=&dadosConsulta.nuProcesso=&dadosConsulta.nuProcessoAntigo=&classeTreeSelection.values=&classeTreeSelection.text=&assuntoTreeSelection.values=10467&assuntoTreeSelection.text=',
                    URLencode(search_data$Assunto[i]), '&agenteSelectedEntitiesList=&contadoragente=0&contadorMaioragente=0&cdAgente=&nmAgente=&dadosConsulta.dtInicio=&dadosConsulta.dtFim=',
                    URLencode(date), '&varasTreeSelection.values=', URLencode(varas_value),'&varasTreeSelection.text=',
                    URLencode(new_varas), '&dadosConsulta.ordenacao=DESC'
                )

                response2 <- GET(url2, add_headers(`User-Agent` = user_agent))
                html_content2 <- content(response2, as = "text", encoding = "UTF-8")
                page2 <- read_html(html_content2)
                
                # Extract results
                results2 <- page2 %>% html_node("td#tdResultados") %>% html_text(trim = TRUE)

                # Sample text data
                text_data2 <- paste(results2, collapse = "\n")
                
                # Split cases and parse each case
                cases2 <- str_split(text_data2, "(?=TRIBUNAL DE JUSTIÇA DO ESTADO DE SÃO PAULO)")[[1]]

                case_data_list2 <- list()
                for(case2 in cases2){
                    case_data2 <- parse_case(case2, search_key)
                    case_data_list2 <- append(case_data_list2, list(case_data2))
                }
                # Append the parsed case data to the results list
                results_list2 <- do.call(rbind, case_data_list2)
                results_list2$Processo <- c(results_list2$Processo[-1], NA)
                results_list2 <- results_list2[!is.na(results_list2$Processo), ]
                write.table(results_list2, 'result.csv', append = TRUE, row.names = FALSE, col.names = FALSE, sep = ',')
                page = page2
            }
            else {
                
                break
            }
        } else {
            print("no number length")
            break
        }
    }
  
}

print("The result saved as result.csv")




