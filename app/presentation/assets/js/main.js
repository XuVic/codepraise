var pre_path = ''

window.onload = function(){
  if (in_path('root')) {
    console.log('In the root path.')
    search_btn = document.getElementById('search-btn')
    search_btn.addEventListener('click', search_project)
    alert_btn = document.querySelector('.close')
    alert_btn.addEventListener('click', function(){
      this.parentElement.classList.add('hidden')
    });
  }

  if (in_path('appraisal')) {

    console.log('In the appraisal path.')
    charts = create_all_chart()
    change_page();

    if (in_path('overview') || in_path('productivity')){
      console.log('overview/productivity')
      data = document.querySelector(".double-slider").dataset
      unit_selector = document.querySelector("#unit_selector")
      start_date = document.querySelector(".double-slider .label #start")
      end_date =  document.querySelector(".double-slider .label #end")
      start_date.textContent = new Date(data.first).getDateString()
      end_date.textContent = new Date(data.last).getDateString()

      $( function() {
        $( "#slider-range" ).slider({
          range: true,
          min: 1,
          max: data.days,
          values: [ 1, data.days ],
          slide: function( event, ui ) {
            first_date = new Date(data.first)
            last_date = new Date(data.last)
            start_date.textContent = first_date.addDays(ui.values[0]).getDateString()
            end_date.textContent = last_date.removeDays(data.days - ui.values[1]).getDateString()
          },
          stop: function(event, ui) {
            unit = unit_selector.value
            update(charts, `between=${start_date.textContent}_${end_date.textContent}&unit=${unit}`)
          }
        });
      });

      unit_selector.addEventListener('change', function(){
        unit = this.value
        update(charts, `between=${start_date.textContent}_${end_date.textContent}&unit=${unit}`)
      })
    }

    if (in_path('quality')){
      console.log('quality')
      issue_selectors = document.querySelectorAll('.c-board .selector select')
      issue_selectors.forEach(function(select){
        select.addEventListener('change', function(){
          issue = issue_selectors[0].value
          email_id = issue_selectors[1].value
          console.log(`issue=${issue}&email_id=${email_id}`)
          update(charts, `issue=${issue}&email_id=${email_id}`)
        })
      })
    }

    if (in_path('ownership')){
      console.log('ownership')
      project_ownership_chart = charts.find((chart) =>{
        return chart.id == 'project_ownership'
      })
      project_ownership_chart.canvas.addEventListener('click', function(e){
        eventElement = project_ownership_chart.chart.getElementAtEvent(e)[0]

        if(eventElement == undefined) return;

        path = project_ownership_chart.chart.data.labels[eventElement._index];
        console.log(path)
        update(charts, `path=${path}`)
        update_pre(path)
      });

      function update_pre(path){
        paths = path.split('/')
        if (path.length > 2 && paths[0] != ''){
          pre_path = paths.slice(0, -1).join('/')
        }
      }

      preBtn = document.querySelector('#pre');
      preBtn.addEventListener('click', function(e){
        update(charts, `path=${pre_path}`)
        update_pre(pre_path)
      })

      ownership_selector = document.querySelector('#ownership_selector');
      ownership_selector.addEventListener('change', function(e){
        update(charts, `email_id=${this.value}`)
      });
    }

    if(in_path('functionality')){
      console.log('functionality')
      keywords_chart = charts.find((chart) =>{
        return chart.id == 'keywords'
      })

      keywords_chart.canvas.addEventListener('click', function(e){
        eventElement = keywords_chart.chart.getElementAtEvent(e)[0]

        if(eventElement == undefined) return;

        keyword = keywords_chart.chart.data.labels[eventElement._index];
        update(charts, `keyword=${keyword}`)
      });

    }

    if(in_path('files')){
      folder_menu()
    }
  }
}

