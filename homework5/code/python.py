from IPython import get_ipython
get_ipython().magic('reset -sf')

# Import packages
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import seaborn as sns
import statsmodels.api as sm
from scipy import stats
from datetime import date
from statsmodels.sandbox.regression import gmm



##Use if at home
# datapath = r'C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework5\data'
# outputpath = r'C:\Users\Owner\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework5\output'

##Use if in the office. Don't forget to switch, moron!
datapath = r'C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework5\data'
outputpath = r'C:\Users\dwilson321\Dropbox\Personal\Enviro Econ II\phdee-2023-DW\homework5\output'

#import data
data=pd.read_csv(datapath +'/instrumentalvehicles.csv')


#Q1
ols1=sm.OLS(data['price'],sm.add_constant(data['mpg'])).fit()
print(ols1.summary())

#Q2
# First stage mpg on weight (instrument) and car type
first_stage_a=sm.OLS(data['mpg'],sm.add_constant(data[['weight','car']])).fit()
data['mpg_hat_a']=first_stage_a.predict(sm.add_constant(data[['weight','car']]))
f_stat_a=first_stage_a.fvalue
second_stage_a=sm.OLS(data['price'],sm.add_constant(data[['mpg_hat_a','car']])).fit()
beta_a=second_stage_a.params
se_a=second_stage_a.HC1_se


# Generate variables weight^2
data['weight2']=data['weight']**2

# First stage mpg on weight (instrument) and car type
first_stage_b=sm.OLS(data['mpg'],sm.add_constant(data[['weight2','car']])).fit()
data['mpg_hat_b']=first_stage_b.predict(sm.add_constant(data[['weight2','car']]))
f_stat_b=first_stage_b.fvalue
second_stage_b=sm.OLS(data['price'],sm.add_constant(data[['mpg_hat_b','car']])).fit()
beta_b=second_stage_b.params
se_b=second_stage_b.HC1_se


# First stage mpg on weight (instrument) and car type
first_stage_c=sm.OLS(data['mpg'],sm.add_constant(data[['height','car']])).fit()
data['mpg_hat_c']=first_stage_c.predict(sm.add_constant(data[['height','car']]))
f_stat_c=first_stage_c.fvalue
second_stage_c=sm.OLS(data['price'],sm.add_constant(data[['mpg_hat_c','car']])).fit()
beta_c=second_stage_c.params
se_c=second_stage_c.HC1_se

report_table=pd.DataFrame(
    {'Weight': ["{:0.2f}".format(beta_a['mpg_hat_a']), "({:0.2f})".format(se_a['mpg_hat_a']), 
             "{:0.2f}".format(beta_a['car']), "({:0.2f})".format(se_a['car']),
             "Weight","{:0.2f}".format(f_stat_a)],
     'Weight$^2$': ["{:0.2f}".format(beta_b['mpg_hat_b']), "({:0.2f})".format(se_b['mpg_hat_b']), 
             "{:0.2f}".format(beta_b['car']), "({:0.2f})".format(se_b['car']),
             "Weight$^2$","{:0.2f}".format(f_stat_b)],
     'Height': ["{:0.2f}".format(beta_c['mpg_hat_c']), "({:0.2f})".format(se_c['mpg_hat_c']), 
             "{:0.2f}".format(beta_c['car']), "({:0.2f})".format(se_c['car']),
             "Height","{:0.2f}".format(f_stat_c)]},
     index=['Miles per gallon', ' ',
            'Car type (=1 if sedan)', ' ',
            '\midrule Instrumental variable',
            'First Stage F-statistic'])
report_table.to_latex(outputpath + '/tables/twostage.tex', column_format='lccc', float_format="%.2f", escape=False)


#Q4
#IVGMM 
iv_gmm=IVGMM(data['price'],sm.add_constant(data['car']),data['mpg'],data['weight']).fit()
beta_gmm=iv_gmm.params
se_gmm=iv_gmm.std_errors

report_table=pd.DataFrame(
    {'2SLS': ["{:0.2f}".format(beta_a['mpg_hat_a']), "({:0.2f})".format(se_a['mpg_hat_a']), 
             "{:0.2f}".format(beta_a['car']), "({:0.2f})".format(se_a['car'])],
     'IVGMM': ["{:0.2f}".format(beta_gmm['mpg']), "({:0.2f})".format(se_gmm['mpg']), 
             "{:0.2f}".format(beta_gmm['car']), "({:0.2f})".format(se_gmm['car'])]},
     index=['Miles per gallon', ' ',
            '=1 if the vehicle is sedan', ' '])
report_table.to_latex(outputpath + '/tables/IVGMM.tex', column_format='lcc', float_format="%.2f", escape=False)