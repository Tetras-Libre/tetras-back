$(function() {
    var myInterval0 = setInterval(function(){
        $.get('discs.php', function(data) {
            $('#discs').html(data);
        });
    }, 15000);
});
