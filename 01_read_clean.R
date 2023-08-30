library(tidyverse)

complications_orig = read_csv(Sys.getenv("epic_patient_post_op_complications"))

complications_all = complications_orig %>% 
  janitor::clean_names() %>% 
  distinct() %>% 
  rename(comp_abbr    = element_abbr,
         complication = smrtdta_elem_value) %>% 
  mutate(complication = if_else(is.na(complication), "Unknown", complication)) %>% 
  mutate(comp_abbr = str_replace(comp_abbr, "AN Post-op Complications", "Post-op AN"))

complications = complications_all %>% 
  arrange(comp_abbr) %>% 
  summarise(.by = c(log_id, mrn),
            any_complication   = if_else(all(complication == "None"), "No", "Yes"),
            n_complications    = sum(complication != "None"),
            complications_abbr = paste(unique(comp_abbr), collapse = ", "),
            complications_full = paste(unique(complication), collapse = ", ")) %>% 
  #count(no_complications)
  mutate(complications_abbr = case_when(any_complication   == "No"          ~ "No complications",
                                        complications_abbr == "Post-op AN" ~ "Unknown",
                                        TRUE ~ str_remove(complications_abbr, "Post-op AN, |, Post-op AN")))
#count(no_complications)


