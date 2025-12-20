-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 20, 2025 at 02:50 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rumahku_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `material_requests`
--

CREATE TABLE `material_requests` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `mandor_id` int(11) NOT NULL,
  `material_name` varchar(200) NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `unit` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('pending','approved','rejected','delivered') DEFAULT 'pending',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `material_requests`
--

INSERT INTO `material_requests` (`id`, `project_id`, `mandor_id`, `material_name`, `quantity`, `unit`, `description`, `status`, `approved_by`, `approved_at`, `created_at`, `updated_at`) VALUES
(1, 2, 4, 'Semen Tiga Roda', 50.00, 'Sak', 'Untuk pengecoran lantai 1', 'approved', 1, '2025-12-18 11:11:54', '2025-12-14 15:51:00', '2025-12-18 11:11:54'),
(2, 2, 4, 'Pasir Beton', 5.00, 'Truk', 'Pasir kualitas super', 'approved', 3, '2025-12-14 15:51:00', '2025-12-14 15:51:00', '2025-12-14 15:51:00'),
(3, 1, 4, 'Semen Gresik', 50.00, 'sak', 'Untuk pekerjaan cor', 'pending', NULL, NULL, '2025-12-14 16:30:43', '2025-12-14 16:30:43'),
(4, 5, 4, 'Pasir', 3.00, 'sak', 'Halaman', 'pending', NULL, NULL, '2025-12-14 18:21:00', '2025-12-14 18:21:00'),
(5, 6, 4, 'Semen', 2.00, 'sak', 'Untuk dinding', 'pending', NULL, NULL, '2025-12-18 13:10:57', '2025-12-18 13:10:57'),
(6, 6, 4, 'Pasir', 1.00, 'Sak', 'Pasir untuk halamnan', 'approved', 3, '2025-12-18 21:38:15', '2025-12-18 21:36:24', '2025-12-18 21:38:15');

-- --------------------------------------------------------

--
-- Table structure for table `projects`
--

CREATE TABLE `projects` (
  `id` int(11) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `budget` decimal(15,2) DEFAULT NULL,
  `status` enum('planning','ongoing','completed','suspended') DEFAULT 'planning',
  `user_id` int(11) NOT NULL,
  `kepala_proyek_id` int(11) NOT NULL,
  `mandor_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `projects`
--

INSERT INTO `projects` (`id`, `name`, `description`, `location`, `start_date`, `end_date`, `budget`, `status`, `user_id`, `kepala_proyek_id`, `mandor_id`, `created_at`, `updated_at`) VALUES
(1, 'Renovasi Rumah Pak Budi', 'Renovasi bagian dapur dan ruang tamu', 'Banjarbaru, Komp. Mawar', '2025-01-01', '2025-03-01', 50000000.00, 'completed', 2, 3, 4, '2025-12-14 15:51:00', '2025-12-18 13:50:25'),
(2, 'Pembangunan Ruko 2 Lantai', 'Ruko untuk usaha laundry', 'Banjarbaru, Jl. A. Yani', '2025-02-01', '2025-08-01', 250000000.00, 'completed', 2, 3, 4, '2025-12-14 15:51:00', '2025-12-16 17:46:13'),
(3, 'Pembuatan Pagar Minimalis', 'Pagar besi hollow galvanis', 'Banjarbaru, Jl. Karang Anyar', '2025-03-01', '2025-03-15', 15000000.00, 'ongoing', 2, 3, 4, '2025-12-14 07:58:41', '2025-12-18 13:36:10'),
(4, 'Pembuatan Pagar Minimalis', 'Pagar besi hollow galvanis', 'Banjarbaru, Jl. Karang Anyar', '2025-03-01', '2025-03-15', 15000000.00, 'suspended', 2, 3, 4, '2025-12-14 16:28:48', '2025-12-14 18:15:26'),
(5, 'Renovasi Halaman Pak Budi', 'Pembuatan Halaman', 'Jalan Cahaya', '2025-12-15', '2025-12-31', 10000000.00, 'ongoing', 2, 3, 4, '2025-12-14 18:12:49', '2025-12-15 17:30:47'),
(6, 'Renovasi rumah baru', 'renovasi rumah baru', 'jalan merbabu 2', '2025-12-19', '2025-12-31', 75000000.00, 'planning', 2, 3, 4, '2025-12-18 11:10:53', '2025-12-18 11:10:53'),
(7, 'Renovasi rumah pak abdul', 'Renovasi rumah dan cat', 'jalan menteng 2', '2025-12-18', '2025-12-31', 100000000.00, 'ongoing', 10, 11, 14, '2025-12-18 13:35:03', '2025-12-18 13:35:03'),
(8, 'Renovasi Rumah', 'Renovasi rumah Pak budi santoso', 'Jalan cahaya 2', '2025-12-19', '2025-12-31', 100000000.00, 'planning', 2, 7, 5, '2025-12-18 21:33:58', '2025-12-18 21:33:58');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `mandor_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `progress` decimal(5,2) NOT NULL,
  `description` text NOT NULL,
  `kendala` text DEFAULT NULL,
  `jumlah_tenaga_kerja` int(11) DEFAULT 0,
  `photo` varchar(255) DEFAULT NULL,
  `status` enum('menunggu','diverifikasi') DEFAULT 'menunggu',
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reports`
--

INSERT INTO `reports` (`id`, `project_id`, `mandor_id`, `date`, `progress`, `description`, `kendala`, `jumlah_tenaga_kerja`, `photo`, `status`, `verified_by`, `verified_at`, `created_at`, `updated_at`) VALUES
(1, 2, 4, '2025-02-07', 10.50, 'Pondasi cakar ayam selesai, lanjut slop bawah.', 'Hujan deras sore hari', 8, NULL, 'diverifikasi', 3, '2025-12-14 15:51:00', '2025-12-14 15:51:00', '2025-12-14 15:51:00'),
(2, 2, 4, '2025-02-14', 20.00, 'Pemasangan bata merah lantai 1 dimulai.', 'Tidak ada kendala', 10, NULL, 'diverifikasi', 3, '2025-12-14 18:17:42', '2025-12-14 15:51:00', '2025-12-14 18:17:42'),
(3, 5, 4, '2025-12-15', 50.00, 'Menambah Paving', NULL, 4, NULL, 'menunggu', NULL, NULL, '2025-12-14 18:20:37', '2025-12-14 18:20:37'),
(4, 5, 4, '2025-12-15', 75.00, 'Halaman sudah rampung, tinggal finishing', 'hujan', 5, NULL, 'diverifikasi', 3, '2025-12-14 20:34:07', '2025-12-14 20:25:12', '2025-12-14 20:34:07'),
(5, 2, 4, '2025-12-16', 80.00, 'Finishing 80%', '', 6, '1765909580_c9eb50e11a7edd65b1ac.jpg', 'menunggu', NULL, NULL, '2025-12-16 10:26:20', '2025-12-16 10:26:20'),
(6, 1, 4, '2025-12-16', 90.00, 'Finishing rumah pak budi', 'Hujan', 5, '1765915012_7bf4d528c4635dbad372.jpg', 'menunggu', NULL, NULL, '2025-12-16 11:56:52', '2025-12-16 11:56:52'),
(7, 3, 4, '2025-12-18', 70.00, 'Renovasi full', 'Hujan', 6, '1766062179_952ad445c3a94e62a904.jpg', 'menunggu', NULL, NULL, '2025-12-18 04:49:39', '2025-12-18 04:49:39'),
(8, 6, 4, '2025-12-18', 25.00, 'Renovasi rumah baru', 'Hujan', 3, '1766092227_63d569cb00687fc07b51.jpg', 'menunggu', NULL, NULL, '2025-12-18 13:10:27', '2025-12-18 13:10:27'),
(9, 6, 4, '2025-12-19', 75.00, 'Renovasi rumah baru', 'Hujan', 4, '1766122546_1f9c13b000f93d2b8b13.jpg', 'diverifikasi', 3, '2025-12-18 21:37:38', '2025-12-18 21:35:46', '2025-12-18 21:37:38');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','pengguna','kepala_proyek','mandor') NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `phone`, `created_at`, `updated_at`) VALUES
(1, 'Admin sistem', 'admin@rumahku.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', '081234567890', '2025-12-14 14:39:16', '2025-12-18 13:46:02'),
(2, 'Budi Santoso', 'budi@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'pengguna', '081234567891', '2025-12-14 14:39:16', '2025-12-14 14:39:16'),
(3, 'Agus Kepala', 'agus@gmail.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'kepala_proyek', '081234567892', '2025-12-14 14:39:16', '2025-12-14 14:39:16'),
(4, 'Joko mandor', 'joko@gmail.com', '$2y$10$j0iAdTQIamyQfsPXw7m3KeFnOS8sWpNTlYjgFIrryX8BNkyU2Ijm6', 'mandor', '081234567893', '2025-12-14 14:39:16', '2025-12-18 13:18:15'),
(5, 'Test User', 'test@example.com', '$2y$10$IHyDrKEYY7y1Q/YEQSaYE.kY.Uq6pnv9ZuWO5pCClYnGJb8q7nHK6', 'mandor', '081234567890', '2025-12-14 07:04:46', '2025-12-14 07:04:46'),
(6, 'Test User', 'hello@example.com', '$2y$10$TcZnZ.w2ppof1SurI66bi.jr3wewFocbTrFAJ0u.1zMrEX2bmiOfi', 'mandor', '081234567890', '2025-12-14 07:27:41', '2025-12-14 07:27:41'),
(7, 'adit', 'adit@gmail.com', '$2y$10$/58DFEYTbochJuZSWBiGoOslAEFgTXtoo2E9UkgenYb6vNJqmlOda', 'kepala_proyek', '082152746477', '2025-12-14 17:48:06', '2025-12-14 17:48:06'),
(8, 'adit kepala', 'adit21@gmail.com', '$2y$10$cgiMQKUUzYoOxXeB8/g36e9Tcr9CVvFVSx8L23joGMFz28nXA9yBO', 'kepala_proyek', '0821527464321', '2025-12-14 18:08:24', '2025-12-14 18:08:24'),
(9, 'Udin', 'udin@gmail.com', '$2y$10$rlc4dIO062pnMf/5TRhNq.q/TA8qLwh0KT0qtsOjadTeIhnfQItaq', 'pengguna', '089827364532', '2025-12-18 10:20:06', '2025-12-18 10:20:06'),
(10, 'Abdul', 'abdul@gmail.com', '$2y$10$4Rba7Zieih3WUwloYT3ufuhLCPl6UyP17JbboMbtPHu84EUrd9YB6', 'pengguna', '098237489283', '2025-12-18 11:13:00', '2025-12-18 11:13:00'),
(11, 'Hakim', 'abdulhakim@gmail.com', '$2y$10$gxuGRG837.z5uyi1jhmwBOJKt2LuhOUzHkaKhCd0Z.8MXDrNCyhLG', 'kepala_proyek', '098237489283', '2025-12-18 12:00:14', '2025-12-18 12:00:14'),
(12, 'maya', 'maya@gmail.com', '$2y$10$PYYHBxtMmzsqA6PKSlJ8iejLUFPtXZVupYpLIiPqPkNT5uUvtWSva', 'pengguna', '09283172312', '2025-12-18 12:11:39', '2025-12-18 12:11:39'),
(13, 'liam', 'liam@gmail.com', '$2y$10$cx0oP33CTj8Vm03ptq9.zO/dG1TBjK.4k/.LGt0wEJpwGGvROkxTe', 'kepala_proyek', '12332112312', '2025-12-18 13:05:57', '2025-12-18 13:05:57'),
(14, 'dora', 'dora@gmail.com', '$2y$10$HMLK.U8URZBnatsUY93yQ.I4fZiP2T6PNyqTPxzDQrQXyZpTd7Zru', 'mandor', '', '2025-12-18 13:06:56', '2025-12-18 13:06:56');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `material_requests`
--
ALTER TABLE `material_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `mandor_id` (`mandor_id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_material_project` (`project_id`),
  ADD KEY `idx_material_status` (`status`);

--
-- Indexes for table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_projects_user` (`user_id`),
  ADD KEY `idx_projects_kepala` (`kepala_proyek_id`),
  ADD KEY `idx_projects_mandor` (`mandor_id`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `mandor_id` (`mandor_id`),
  ADD KEY `verified_by` (`verified_by`),
  ADD KEY `idx_reports_project` (`project_id`),
  ADD KEY `idx_reports_status` (`status`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `material_requests`
--
ALTER TABLE `material_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `material_requests`
--
ALTER TABLE `material_requests`
  ADD CONSTRAINT `material_requests_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `material_requests_ibfk_2` FOREIGN KEY (`mandor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `material_requests_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `projects_ibfk_2` FOREIGN KEY (`kepala_proyek_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `projects_ibfk_3` FOREIGN KEY (`mandor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`mandor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reports_ibfk_3` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
