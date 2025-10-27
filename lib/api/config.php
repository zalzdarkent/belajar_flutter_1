<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "db_mahasiswa";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode([
        "status" => false,
        "message" => "Koneksi gagal: " . $conn->connect_error
    ]));
}
?>
