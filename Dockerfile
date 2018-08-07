# © Copyright IBM Corporation 2018.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html

FROM ppedraza/ace
#FROM ibmcom/ace

ENV BAR1=abc.bar
ENV ODBC=odbc.ini

ARG dbname
ARG dbuser
ARG dbpass

# Copy in the bar file to a temporary directory
COPY --chown=aceuser $BAR1 /tmp

# Copy odbc.ini file to a temporary directory
COPY $ODBC /opt/ibm/ace-11.0.0.0/server/ODBC/unixodbc/

# Unzip the BAR file; need to use bash to make the profile work
RUN bash -c 'mqsicreateworkdir /home/aceuser/ace-server && mqsibar -w /home/aceuser/ace-server -a /tmp/$BAR1 -c'

# Seteo conexion 
RUN bash -c 'mqsisetdbparms -w /home/aceuser/ace-server -n $dbname -u $dbuser -p $dbpass'