$( document ).ready(function() {
    // 1 ul 
    // 0 table
    $('.js--changeDisplay').on('click', function(){
        var self = $(this);
        var sol_name = self.data('sol');

        if(self.data('display') == 1)
        {
            self.data('display', 0);
            $('#ul_' + sol_name).hide();
            $('#table_' + sol_name).show();
        }
        else
        {
            self.data('display', 1);
            $('#ul_' + sol_name).show();
            $('#table_' + sol_name).hide();
        }
    });
});