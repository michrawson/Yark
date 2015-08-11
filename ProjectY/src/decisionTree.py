import pydot
import StringIO
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn import tree
from sklearn.tree import export_graphviz
from IPython.display import Image
from sklearn import ensemble, feature_extraction, preprocessing
from sklearn.preprocessing import Imputer


train = pd.read_csv("decisionTreeInput1.csv", header = None)

# load features and labels
train_data = train.iloc[:, 1:]
labels_data = train.iloc[:,0]

train = train_data.values
labels = labels_data.values

train = Imputer().fit_transform(train)

# build the model and train it
clf = tree.DecisionTreeClassifier(criterion='entropy', min_samples_leaf = 3, max_depth=5)

clf.fit(train, labels)


# create visualization

dot_data = StringIO.StringIO()
tree.export_graphviz(clf, out_file=dot_data)
graph = pydot.graph_from_dot_data(dot_data.getvalue())
graph.write_pdf("decisionTree.pdf")




