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
    <div class="container mt-5">
        <form action="SQLindex.php" method="post" class="form-inline">
            <div class="form-group mb-2">
                <label >Entrer un num_compte : </label>
            </div>
            <div class="form-group mx-sm-3 mb-2">
                <label  class="sr-only">Password</label>
                <input class="form-control" name="num" placeholder="num_compte">
            </div>
            <button type="submit" class="btn btn-outline-primary mb-2">Submit</button>
        </form>

    </div>
</body>
</html>