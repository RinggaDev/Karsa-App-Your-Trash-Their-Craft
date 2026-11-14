// karsa-backend/scripts/seed-umkm.js
// Run with: node --env-file=.env scripts/seed-umkm.js
import { supabase } from '../src/config/supabase.js'

const data = [
  {
    nama: 'Kreasi Nusantara',
    deskripsi: 'Kerajinan tas dan aksesori dari plastik daur ulang.',
    lokasi: 'Bandung, Jawa Barat',
    bahan_baku: ['plastik'],
    produk_dibuat: 'Tas belanja, dompet, dan pouch daur ulang',
    kontak: 'kreasi.nusantara@email.com',
    gambar_url: null,
  },
  {
    nama: 'PlastiKoe Studio',
    deskripsi: 'Mengolah limbah botol dan kantong plastik menjadi ubin dekoratif dan tatakan gelas.',
    lokasi: 'Jakarta Selatan, DKI Jakarta',
    bahan_baku: ['plastik'],
    produk_dibuat: 'Coaster, vas bunga estetik, dan gantungan kunci',
    kontak: 'halo@plastikoe.id',
    gambar_url: null,
  },
  {
    nama: 'EcoPolymer Kreasi',
    deskripsi: 'Pengolahan plastik kemasan sachet menjadi wadah multifungsi tahan lama.',
    lokasi: 'Surabaya, Jawa Timur',
    bahan_baku: ['plastik', 'kertas'],
    produk_dibuat: 'Kotak penyimpanan, pot sukulen, organizer meja',
    kontak: 'ecopolymer.sub@gmail.com',
    gambar_url: null,
  },
  {
    nama: 'Kayu Lestari Art',
    deskripsi: 'Studio kriya yang menyulap limbah palet dan potongan kayu sisa furniture.',
    lokasi: 'Yogyakarta, DI Yogyakarta',
    bahan_baku: ['kayu'],
    produk_dibuat: 'Jam dinding kayu, rak serbaguna, sendok garpu kayu',
    kontak: 'kayulestari.art@gmail.com',
    gambar_url: null,
  },
  {
    nama: 'Reka Kayu Nusantara',
    deskripsi: 'Pemanfaatan ranting dan serpihan kayu bekas proyek interior.',
    lokasi: 'Jepara, Jawa Tengah',
    bahan_baku: ['kayu'],
    produk_dibuat: 'Bingkai foto minimalis, dudukan ponsel, pajangan meja',
    kontak: 'rekakayu.jepara@yahoo.com',
    gambar_url: null,
  },
  {
    nama: 'Perca Ceria',
    deskripsi: 'Komunitas ibu-ibu penjahit yang memanfaatkan kain perca sisa konveksi.',
    lokasi: 'Solo, Jawa Tengah',
    bahan_baku: ['kain'],
    produk_dibuat: 'Tote bag perca, celemek masak, sarung bantal motif patchwork',
    kontak: 'percaceria.solo@gmail.com',
    gambar_url: null,
  },
  {
    nama: 'Benang Karsa',
    deskripsi: 'Workshop pengolahan limbah tekstil denim dan katun menjadi fashion item.',
    lokasi: 'Tangerang Selatan, Banten',
    bahan_baku: ['kain'],
    produk_dibuat: 'Topi bucket, jaket daur ulang, tempat pensil',
    kontak: 'admin@benangkarsa.co.id',
    gambar_url: null,
  },
  {
    nama: 'Kertas Kembara',
    deskripsi: 'Membuat kertas daur ulang bertekstur unik berbahan kardus dan kertas bekas.',
    lokasi: 'Malang, Jawa Timur',
    bahan_baku: ['kertas'],
    produk_dibuat: 'Buku catatan artisan, amplop surat berbunga, gift card',
    kontak: 'kertaskembara@gmail.com',
    gambar_url: null,
  },
  {
    nama: 'Daur Box ID',
    deskripsi: 'Spesialis pengolahan karton tebal dan koran bekas untuk kemasan ramah lingkungan.',
    lokasi: 'Semarang, Jawa Tengah',
    bahan_baku: ['kertas'],
    produk_dibuat: 'Hardbox hampers, divider laci, paper bag daur ulang',
    kontak: 'info@daurbox.id',
    gambar_url: null,
  },
  {
    nama: 'Logam Mulia Rongsok',
    deskripsi: 'Peleburan dan pemanfaatan kaleng aluminium dan tutup botol logam bekas.',
    lokasi: 'Bekasi, Jawa Barat',
    bahan_baku: ['logam'],
    produk_dibuat: 'Asbak daur ulang, miniatur kendaraan kaleng, medali suvenir',
    kontak: 'lm.rongsok@gmail.com',
    gambar_url: null,
  },
]

async function seed() {
  console.log('Seeding UMKM data...')
  const { data: inserted, error } = await supabase.from('umkm').insert(data).select()
  if (error) {
    console.error('Seed error:', error.message)
    process.exit(1)
  }
  console.log(`Berhasil seed ${inserted.length} data UMKM!`)
  process.exit(0)
}

seed()

