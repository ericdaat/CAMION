###############################################################
# CAMION: Catchment Area MaximizatION with linear programming #
###############################################################

# Load libraries ---------------------------------------------------------------
library(geojsonio)
library(broom)
library(sf)
library(osmdata)
library(ggplot2)
library(dplyr)
library(ggnewscale)
library(ggsci)
library(ggfittext)
library(ggpubr)

# Configuration variables ------------------------------------------------------

BASE_SIZE <- 14

# Custom colors ----------------------------------------------------------------

# https://coolors.co/ffbe0b-fb5607-ff006e-8338ec-3a86ff
COLORS_COUNTY <- c(
  "Queens"="#FFBE0B",
  "Kings"="#FB5607",
  "Bronx"="#FF006E",
  "New York"="#8338EC",
  "Richmond"="#3A86FF"
)

# Load geojson data ------------------------------------------------------------
spdf_file <- geojson_read(
  "data/zip_code_040114.geojson",
  what = "sp"
)
spdf_file <- tidy(
  spdf_file,
  region="ZIPCODE"
)

# Load health dataset ----------------------------------------------------------

facilities_with_capacities <- read.csv(
  "results/csv/facilities_with_capacities.csv"
)

pop_locations <- read.csv(
  "results/csv/pop_locations.csv",
  colClasses = c("ZIPCODE"="character")
)

# Figure 1: Hospitals with Medical / Surgery beds in New York City -------------

fig1_a <- ggplot() +
  geom_polygon(data=spdf_file,
               aes(x=long,
                   y=lat,
                   group=group),
               color="black",
               alpha=0,
               size=.1) +
  geom_point(data=facilities_with_capacities,
             aes(x=Facility.Longitude,
                 y=Facility.Latitude,
                 size=Measure.Value,
                 fill=Facility.County),
             shape=22) +
  scale_size_binned(range = c(.5, 5)) +
  coord_map() +
  scale_fill_manual(values=COLORS_COUNTY) +
  theme_void(base_size = BASE_SIZE) +
  theme(legend.position="bottom") +
  guides(size=guide_legend(title.position="top", nrow=2),
         fill=guide_legend(title.position="top", nrow=2)) +
  labs(size="Number of beds",
       fill="Hospital county")

fig1_b <- facilities_with_capacities %>% 
  ggplot(aes(x=Measure.Value,
             fill="")) +
    geom_histogram(color="black",
                   bins=10) +
    theme_classic(base_size = BASE_SIZE) +
    scale_fill_jama(guide="none") +
    labs(x="Number of beds",
         y="Number of hospitals")

fig1_c <- facilities_with_capacities %>% 
  top_n(n=25, wt=Measure.Value) %>% 
  ggplot(aes(x=reorder(Facility.Name, Measure.Value),
             y=Measure.Value,
             fill=Facility.County)) +
    geom_bar(stat="identity") +
    geom_bar_text() +
    coord_flip() +
    scale_fill_manual(values=COLORS_COUNTY, guide="none") +
    theme_classic(base_size = BASE_SIZE) +
    theme(legend.position="top") +
    labs(x="Hospital name",
         y="Number of beds",
         fill="Hospital county")

fig1 <- ggarrange(
  fig1_a,
  ggarrange(fig1_b, fig1_c,
            heights = c(.3, .7),
            nrow=2, ncol = 1,
            labels=c("B", "C")),
  nrow=1, ncol=2,
  labels=c("A", "")
)

ggsave(
  fig1, 
  filename="fig1.png",
  path = "results/figures", 
  width = 15,
  height = 10,
  dpi = 300
)

# Figure 2: Accessibility to Medical / Surgery beds in New York City -----------

fig2_a <- ggplot() +
  geom_polygon(data=spdf_file %>% 
                 inner_join(pop_locations, c("id"="ZIPCODE")),
               aes(x=long,
                   y=lat,
                   group=group,
                   fill=A_i),
               color="black",
               size=.1) +
  geom_point(data=facilities_with_capacities,
             aes(x=Facility.Longitude,
                 y=Facility.Latitude,
                 size=Measure.Value,
                 color=Facility.County),
             shape=0) +
  coord_map() +
  scale_size_binned(range = c(.5, 5)) +
  scale_fill_distiller(palette = "YlGn", direction = 1) +
  scale_color_manual(values=COLORS_COUNTY, guide="none") +
  theme_void(base_size = BASE_SIZE) +
  theme(legend.position="bottom") +
  guides(size=guide_legend(title.position="top", nrow=2),
         fill=guide_legend(title.position="top", nrow=2)) +
  labs(size="Number of beds",
       fill="Accessibility score")

fig2_b <- pop_locations %>% 
  ggplot(aes(x=A_i, fill="")) +
  geom_histogram(bins=20, color="black") +
  theme_classic(base_size = BASE_SIZE) +
  scale_fill_jama(guide="none") +
  labs(x="Accessibility score",
       y="Number of Zip Codes")

fig2_c <- pop_locations %>% 
  group_by(COUNTY) %>% 
  mutate(median_A_i=median(A_i)) %>% 
  ggplot(aes(x=reorder(COUNTY, -median_A_i),
             y=A_i,
             fill=COUNTY)) +
    geom_boxplot() +
    geom_jitter(width = .1, alpha=.3) +
    theme_classic(base_size = BASE_SIZE) +
    scale_fill_manual(values=COLORS_COUNTY, guide="none") +
    labs(x="County",
         y="Accessibility score")

fig2_d <- pop_locations %>% 
  ggplot(aes(x=POPULATION,
             y=A_i,
             fill=COUNTY)) +
    geom_point(shape=21,
               size=4) +
    theme_classic(base_size = BASE_SIZE) +
    scale_fill_manual(values=COLORS_COUNTY, guide="none") +
    labs(x="Population",
         y="Accessibility score")
  
fig2 <- ggarrange(
  fig2_a,
  ggarrange(fig2_b, fig2_c, fig2_d,
            heights = c(.3, .3, .3),
            nrow=3, ncol = 1,
            labels=c("B", "C", "D")),
  nrow=1, ncol=2,
  labels=c("A", "")
)

ggsave(
  fig2, 
  filename="fig2.png",
  path = "results/figures", 
  width = 15,
  height = 10,
  dpi = 300
)
  
  
  
  
