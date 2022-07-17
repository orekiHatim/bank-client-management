<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
</head>
<body>
    
</body>
</html>




<?php
function OpenConnection()
{
    $serverName = "DESKTOP-UA03MBK";
    $connectionOptions = array("Database"=>"banque",
        "Uid"=>"TOUGUI-HATIM", "PWD"=>"123");
    $conn = sqlsrv_connect($serverName, $connectionOptions);
    if($conn == false)
        die(print_r(sqlsrv_errors(), true));

    return $conn;
}

?>
<div class="container mt-5">
<legend class="text-white bg-danger text-center">RELEVE COMPTE</legend>
    <table class="table table-hover">
        <th>LIBELLE</th>
        <th>SOLDE</th>
        <th>DECOUVERT</th>
        <th>NUM CLIENT</th>
        <th>TYPE COMPTE</th>
        <th>NOM CLIENT</th>
        <th>ADRESSE</th>
        <th>MOT DE PASSE</th>
        <th>DATE DE CONSULTATION</th>
            <?php

            try
                    {
                        $conn = OpenConnection();
                        $num = $_POST['num'];
                        $tsql = "SELECT * FROM releve_compte($num)";
                        $getReleve = sqlsrv_query($conn, $tsql);
                        if ($getReleve == FALSE)
                            die(print_r(sqlsrv_errors()));
                        
                        while($row = sqlsrv_fetch_array($getReleve, SQLSRV_FETCH_ASSOC))
                        {
                            echo("<tr>");
                            foreach($row as $key => $val){
                                echo("<td>");
                                if ($key == 'date_derniere_consultation'){
                                    $v = $val->format('Y-m-d');
                                    echo($v);
                                }
                                else{
                                    echo($val);
                                }
                                
                                echo("</td>");
                            }
                            echo("</tr>");
                            
                            
                            

                            
                        }
                        sqlsrv_free_stmt($getReleve);
                        sqlsrv_close($conn);
                    }
                    catch(Exception $e)
                    {
                        echo("Error!");
                    }


            ?>
   </table>
</div>

<div class="container mt-5">
<legend class="text-white bg-danger text-center">RELEVE OPERATION</legend>
<table class="table table-hover">
        <th>LIBELLE</th>
        <th>MONTANT</th>
        <th>DATE</th>
        <th>TYPE</th>
        <?php
            try
            {
                $conn = OpenConnection();
                $num = $_POST['num'];
                $tsql = "SELECT * FROM releve_operations($num)";
                $getReleve = sqlsrv_query($conn, $tsql);
                if ($getReleve == FALSE)
                    die(print_r(sqlsrv_errors()));
                
                while($row = sqlsrv_fetch_array($getReleve, SQLSRV_FETCH_ASSOC))
                {
                    echo("<tr>");
                    foreach($row as $key => $val){
                        echo("<td>");
                        if ($key == 'date_operation'){
                            $v = $val->format('Y-m-d');
                            echo($v);
                        }
                        else{
                            echo($val);
                        }
                        
                        echo("</td>");
                    }
                    echo("</tr>");
                    
                    
                    

                    
                }
                sqlsrv_free_stmt($getReleve);
                sqlsrv_close($conn);
            }
            catch(Exception $e)
            {
                echo("Error!");
            }
        ?>

</table>
</div>