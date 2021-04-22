window.addEventListener('message', function(event) {
    let item = event.data;

    if (item.type == 'openTarget') {
        $(".target-label").html("");
        
        $('.target-wrapper').show();

        $(".target-eye").css("color", "black");
    } else if (item.type == 'closeTarget') {
        $(".target-label").html("");

        $('.target-wrapper').hide();
    } else if (item.type == 'validTarget') {
        $(".target-label").html("");

        var count = 0;
        var labelCount = 0;
        $.each(item.data, function (index, data) {
          var _c = labelCount;
          $(".target-label").append("<div class='header' id='label-"+labelCount+"'<li><span class='target-icon'><i class='"+data.icon+"'></i></span>&nbsp"+data.label+"</li></div>");
          $("#label-"+labelCount+"").css("padding-top", "6px");
          labelCount++;
            
          $.each(data.options, function (i,opt) {
            var c = count;
            $(".target-label").append("<div id='target-"+count+"'<li>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp"+opt.label+"</li></div>");
            $("#target-"+count).hover((e)=> {
                $("#target-"+c).css("color",e.type === "mouseenter"?"rgb(30,144,255)":"white")
            })
            
            $("#target-"+count+"").css("padding-top", "6px");

            $("#target-"+count).data('TargetData', {parentName:data.name,name:opt.name});
            count++;
          });
        });

        $(".target-eye").css("color", "rgb(30,144,255)");
    } else if (item.type == 'leftTarget') {
        $(".target-label").html("");

        $(".target-eye").css("color", "black");
    }
});

$(document).on('mousedown', (event) => {
    let element = event.target;

    if (element.id.split("-")[0] === 'target') {
        let TargetData = $("#"+element.id).data('TargetData');

        $.post('https://fivem-target/select', JSON.stringify(TargetData));

        $(".target-label").html("");
        $('.target-wrapper').hide();
    }
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESC
            $(".target-label").html("");
            $('.target-wrapper').hide();
            $.post('http://fivem-target/closed');
            break;
    }
});