import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AlatService {
  Future<List<Map<String, dynamic>>> getAlat() async {
    final response = await supabase
        .from('alat')
        .select('''
          id_alat,
          nama_alat,
          kondisi,
          jumlah_total,
          jumlah_tersedia,
          gambar_alat,
          kategori (
            id_kategori,
            nama_kategori
          )
        ''')
        .order('nama_alat');

    return response;
  }
}
