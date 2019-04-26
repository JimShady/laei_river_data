library(tidyverse)

plot <- read_csv('shipping_profile.csv') %>%
mutate(total = sum(records)) %>%
mutate(ratio = records/total) %>%
ggplot(aes(hour, ratio, group = wday, colour = wday)) +
geom_line(size=1) +
scale_x_continuous(breaks = 0:23) +
xlab('Hour of the day') +
ylab('Ratio') +
theme(legend.title = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text = element_text(colour='black'))
  
png("maps/diurnal_variation.png", width=15, height=5, units='cm', res=300)
plot(plot)
dev.off()
