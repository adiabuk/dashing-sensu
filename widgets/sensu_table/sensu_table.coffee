class Dashing.SensuTable extends Dashing.Widget


   onData: (data) ->

     # Identify team from query string
     # eg. http://dashing.domain.org/sensu?team=devops
     search_query = window.location.search.substring(1)
     [key, team] = search_query.split("=")

     get_columns = (team_config) ->
       # identify list of columns to use and their location
       # in the array of data to be used for filtering
       hrow_cols = []
       columns_to_keep = []

       # if there is no config for the chosen team, then use 'default'
       # but still display only the alarms for that team (not all alarms)
       if not team_config[root.team()]?
         col_team = 'default'
       else
         col_team=root.team()

       for item in team_config[col_team]
         hrow_cols.push({'value': item})
         columns_to_keep.push(data['hrows_tmp'].indexOf(item))

       # return list of column names, and location of the data
       return [hrow_cols, columns_to_keep]

     get_filtered_column = (columns_to_keep, row) ->
       # get a list of data based on list of columns that we are displaying
       cols = []
       urgency = row[1]
       for column in columns_to_keep
         data_hash = {"class": urgency, "value": row[column]}
         cols.push(data_hash)

       # return columns for fiven row
       return cols

     # store team as a root function so can be accessed globablly
     root = exports ? this
     if not team
       team = 'all'
     root.team = -> team

     # init vars
     count = {'critical': 0, 'warning': 0, 'unknown': 0}
     filtered_array = []

     # determine which columns to use
     columns_to_keep = []
     hrow_cols = []
     [hrow_cols, columns_to_keep] = get_columns(data['col_config'])

     filtered_data = []
     filtered_hrows = []
     filtered_hrows.push('cols': hrow_cols)

     # gather data
     for row in data['all_data']
       cols=[]

       if @team() in row or @team() == 'all'

         cols = get_filtered_column(columns_to_keep, row)
         filtered_data.push({'cols': cols})

         if @team() != 'all'
           urgency = row[1]
           count[urgency] += 1  # increment count of urgency

     # set final data

     if @team() == 'all'
       Dashing.widgets['sensu-status'][0]['criticals'] =
         Dashing.widgets['sensu-status'][0]['criticals_tmp']
       Dashing.widgets['sensu-status'][0]['warnings'] =
         Dashing.widgets['sensu-status'][0]['warnings_tmp']
       Dashing.widgets['sensu-status'][0]['unknowns'] =
         Dashing.widgets['sensu-status'][0]['unknowns_tmp']
     else
       Dashing.widgets['sensu-status'][0]['criticals'] = count['critical']
       Dashing.widgets['sensu-status'][0]['warnings'] = count['warning']
       Dashing.widgets['sensu-status'][0]['unknowns'] = count['unknown']

     # set header row of table
     Dashing.widgets['sensu-table'][0]['hrows'] = filtered_hrows
     Dashing.widgets['sensu-table'][0]['rows'] = filtered_data
     Dashing.lastEvents['sensu-table']['rows'] = filtered_data
     Dashing.lastEvents['sensu-table']['hrows'] = filtered_hrows

     # clean-up old data
     Dashing.widgets['sensu-status'][0]['unknowns_tmp'] =''
     Dashing.widgets['sensu-status'][0]['criticals_tmp'] =''
     Dashing.widgets['sensu-status'][0]['warnings_tmp'] =''
     Dashing.widgets['sensu-table'][0]['hrows_tmp'] = ''
     Dashing.widgets['sensu-table'][0]['all_data'] = ''

     # need the following line  as CS will return last line in a given scope
     # when rendered to JS which may cause a fork bomb and
     # eventually kill the browser (and perhaps the whole machine)
     return

   ready: ->
     # This is fired when the widget is done being rendered
     if not Dashing.widgets[@id][0]['rows']?
       console.log('populating with data')
       this.onData(Dashing.widgets[@id][0])
       @mixin(Dashing.lastEvents['sensu-table'])
     else
       console.log('no problems here...')

     return

