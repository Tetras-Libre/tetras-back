$(function() {
    var myInterval = setInterval(function(){
        $.get('log.php', function(data) {
            $('#mainlog').html(data);
        });
    }, 5000);
});
