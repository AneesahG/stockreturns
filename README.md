# Time Series Analysis and GARCH Model testing 

## Prerequisites
You will need [RStudio](https://posit.co/products/open-source/rstudio/). Other packages that are needed are TSA, astsa, tseries, BatchGetSymbols, fGarch and fBasics.

```
{r message=FALSE, warning=FALSE}
library(TSA)
library(astsa)
library(tseries)
library(BatchGetSymbols)
library(fGarch)
library(fBasics)
```

Predictive analysis and GARCH model on stock returns. I demonstrate how to use the PACF (partial autocorrelation function) and ACF (autocorrelation function) on a non stationary time series. The financial data can be pulled using ```GetBatchSymbol```. In this study, I [used VanEck Russia ETF (RSX)](https://finance.yahoo.com/quote/RSX/). 

```
{r message=FALSE, warning=FALSE}
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
### Data Plotting

```
{r, fig.align='center',out.width='75%'}
RSX_open<-as.ts(RSX$df.tickers$price.open)
plot(RSX_open,type="o")
line5<-lm(RSX_open~time(RSX_open))
abline(line5)
```
The data (n=300), which accounts for Russia's ETF (basket of securities and shares sold on exchange) assumes a non-constant, volatile time-varying process. We see an overall increasing trend of price and yield performances that have higher variability with higher share prices. There is a fair amount of volatility near the end of our data approaching the 300th day. This volatility clustering for Russia's equity index in general could be due to geopolitics (i.e, Washington sanctions) and recent protests in Russia. Due to this heteroskedasticity, we will consider an ARCH or GARCH(p,q) model for our VanEck Vectors Russia ETF data. 
Note: (*As of 2023, the war in Ukraine has also impacted the volatility greatly.)*

### Choosing a GARCH Model and ACF/PACF

Below, the stock returns for VanEck Vectors Russia ETF data for the last 300 days (multiplied by 100) has been plotted to further illustrate this volatility.

```
{r}
r.russia=diff(log(RSX_open))*100
plot(r.russia)
abline(h=0)
```
Followed by our ACF and PACF figures for our returns:

```
{r}
acf(r.russia)
pacf(r.russia)
```

Our sample ACF and PACF (multiplied by 100) show little correlation.

If our series is truly independent, nonlinear transformations such as taking the log, absolute value or squaring will not affect this independence.

```
{r}
plot(r.russia^2)
``` 

```
{r}
acf2(r.russia^2,200)
```
```
{r}
rus.sq.ret<-r.russia^2
rus.abs.ret<-abs(r.russia)
```

```
{r}
plot(rus.sq.ret)
plot(rus.abs.ret)
```
Next, we test for heteroscedasticity using the McLeod-Li test: 

```{r}
McLeod.Li.test(y=rus.sq.ret)
```

Clearly, there is much heteroscedasticity, suggesting that an ARCH or GARCH model may be appropriate for the series of returns.

If our series is GARCH, then our squared returns would be [ARMA](https://rpubs.com/JSHAH/481706).

```
{r}
acf2(rus.sq.ret, na.action = na.pass, 20)
```
```
{r}
eacf(rus.sq.ret)
```

Optimially, we will select a classic GARCH(1,1) model as given our options based off the vertex of our EACF table since our ACF/PACF is not clear.

### Estimating Parameters 

```
{r}
rus.ret.model.1<-garch(r.russia,order=c(1,1))
summary(rus.ret.model.1)
```
The results for our parameters appear significant. 

### Residual Analysis 

We will plot the residuals for a GARCH(1,1) model.
```
{r}
plot(residuals(rus.ret.model.1))
```
### Normality Analysis 

The test for normality:
```
{r}
shapiro.test(residuals(rus.ret.model.1))
```
The very small Shapiro p-value suggests non-normal residuals.

```
{r}
qqnorm(residuals(rus.ret.model.1))
```
### Findings

```
{r}
res.rus.ret.model.1<-na.remove(residuals(rus.ret.model.1))
res.rus.ret.model.1
```
```
{r}
runs(res.rus.ret.model.1,k=2)
```
The residuals are large in terms of residual pattern volatility. The QQ plot is also slightly skewed on both ends. Overall, the GARCH(1,1) model is not totally ideal since the residuals are not wholly independently and identically distributed by our above residual analysis results. Perhaps a more generalized GARCH+ARMA model could be considered, or variations of the GARCH(p,q) options from our EACF table that did not overfit. 
