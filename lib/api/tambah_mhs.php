<?php
header("Content-Type: application/json");
include "config.php";

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["status" => false, "message" => "Gunakan metode POST."]);
    exit;
}

$data = json_decode(file_get_contents("php://input"), true);

if (!$data) {
    echo json_encode(["status" => false, "message" => "Data tidak ditemukan."]);
    exit;
}

$nama          = $conn->real_escape_string($data['nama'] ?? '');
$npm           = $conn->real_escape_string($data['npm'] ?? '');
$email         = $conn->real_escape_string($data['email'] ?? '');
$alamat        = $conn->real_escape_string($data['alamat'] ?? '');
$tgl_lahir     = $conn->real_escape_string($data['tglLahir'] ?? '');
$jam_bimbingan = $conn->real_escape_string($data['jamBimbingan'] ?? '');

if (empty($nama) || empty($npm) || empty($email) || empty($tgl_lahir) || empty($jam_bimbingan)) {
    echo json_encode(["status" => false, "message" => "Semua field wajib diisi."]);
    exit;
}

$sql = "INSERT INTO mahasiswa (nama, npm, email, alamat, tglLahir, jamBimbingan)
        VALUES ('$nama', '$npm', '$email', '$alamat', STR_TO_DATE('$tgl_lahir', '%d/%m/%Y'), '$jam_bimbingan')";

if ($conn->query($sql)) {
    echo json_encode(["status" => true, "message" => "Data berhasil disimpan!"]);
} else {
    echo json_encode(["status" => false, "message" => "Gagal: " . $conn->error]);
}

$conn->close();
?>
