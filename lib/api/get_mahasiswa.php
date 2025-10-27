<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include "config.php";

// Cek metode
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(["status" => false, "message" => "Gunakan metode GET."]);
    exit;
}

try {
    // Ambil semua data mahasiswa
    $sql = "SELECT id, nama, npm, email, alamat, tgl_lahir, jam_bimbingan FROM mahasiswa ORDER BY id DESC";
    $result = $conn->query($sql);
    
    if ($result->num_rows > 0) {
        $data = [];
        while($row = $result->fetch_assoc()) {
            // Format tanggal jika ada
            if ($row['tgl_lahir']) {
                $date = new DateTime($row['tgl_lahir']);
                $row['tgl_lahir'] = $date->format('d/m/Y');
            }
            $data[] = $row;
        }
        
        echo json_encode([
            "status" => true, 
            "message" => "Data berhasil diambil",
            "data" => $data,
            "total" => count($data)
        ]);
    } else {
        echo json_encode([
            "status" => true, 
            "message" => "Tidak ada data mahasiswa",
            "data" => [],
            "total" => 0
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        "status" => false, 
        "message" => "Gagal mengambil data: " . $e->getMessage()
    ]);
}

$conn->close();
?>
