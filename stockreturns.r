#'import TSA, astsa, tseries, BatchGetSymbols, fGarch and fBasics.
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
```{r message=FALSE, warning=FALSE}
library(TSA)
library(astsa)
library(tseries)
library(BatchGetSymbols)
library(fGarch)
library(fBasics)
```
#' Use GetBatchSymbol to pull financial data you want. Here, I used RSX.
```{r message=FALSE, warning=FALSE}
library(BatchGetSymbols)
first.date <- Sys.Date() - 300
last.date <- Sys.Date()
freq.data <- 'daily'
RSX <- BatchGetSymbols(tickers = "RSX" ,
                         first.date = first.date,
                         last.date = last.date, 
                         freq.data = freq.data,
                         cache.folder = file.path(tempdir(), 
                                                  'BGS_Cache') )
```                                                                                                    
```{r, fig.align='center',out.width='75%'}
RSX_open<-as.ts(RSX$df.tickers$price.open)
plot(RSX_open,type="o")
line5<-lm(RSX_open~time(RSX_open))
abline(line5)
```                 
```{r}
r.russia=diff(log(RSX_open))*100
plot(r.russia)
abline(h=0)
```
```{r}
acf(r.russia)
pacf(r.russia)
```
```{r}
plot(r.russia^2)
``` 
```{r}
acf2(r.russia^2,200)
```
```{r}
rus.sq.ret<-r.russia^2
rus.abs.ret<-abs(r.russia)
```
```{r}
plot(rus.sq.ret)
plot(rus.abs.ret)
```
```{r}
McLeod.Li.test(y=rus.sq.ret)
```
```{r}
acf2(rus.sq.ret, na.action = na.pass, 20)
```
```{r}
eacf(rus.sq.ret)
```
#'We will plot the residuals for a GARCH(1,1) model.
```{r}
plot(residuals(rus.ret.model.1))
```
#'And test normality:
```{r}
shapiro.test(residuals(rus.ret.model.1))
```
#'The very small Shapiro p-value suggests non-normal residuals.
```{r}
qqnorm(residuals(rus.ret.model.1))
```
```{r}
res.rus.ret.model.1<-na.remove(residuals(rus.ret.model.1))
res.rus.ret.model.1
```
```{r}
runs(res.rus.ret.model.1,k=2)
```
