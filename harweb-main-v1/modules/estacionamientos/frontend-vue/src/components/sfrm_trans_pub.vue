<template>
  <div class="sfrm-trans-pub-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Transferencia de Estacionamientos Públicos</li>
      </ol>
    </nav>
    <h2>Transferencia de datos del HP3000 a PostgreSQL</h2>
    <h4>de estacionamientos públicos</h4>
    <div class="mb-3">
      <input type="file" ref="fileInput" @change="onFileChange" accept=".txt,.dat" />
      <button class="btn btn-primary ms-2" @click="uploadFile" :disabled="!selectedFile">Abrir Archivo</button>
      <span class="ms-3 text-success" v-if="filename">{{ filename }}</span>
    </div>
    <div class="mb-3">
      <button class="btn btn-success me-2" @click="parseFile" :disabled="!fileContent">Pasar Datos</button>
      <button class="btn btn-info me-2" @click="insertRecords" :disabled="!parsedRows.length">Altas</button>
      <button class="btn btn-warning" @click="updatePolFecVen" :disabled="!parsedRows.length">Actualizar Fechas</button>
    </div>
    <div v-if="parsedRows.length">
      <h5>Vista previa de datos (máx. 20 filas)</h5>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th v-for="col in columns" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in parsedRows.slice(0,20)" :key="idx">
              <td v-for="col in columns" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'SfrmTransPub',
  data() {
    return {
      selectedFile: null,
      filename: '',
      fileContent: '',
      parsedRows: [],
      columns: [
        'sector','categoria','numero','nombre','telefono','calle','num','cupo','fec_alta','fec_inic','fec_venci','de_las','a_las','de_las_dom','a_las_dom','lun','mar','mier','jue','vie','sat','dom','pol_num','pol_fec','num_lic','zona','sub_zona','estatus','clave'
      ],
      message: '',
      success: false
    }
  },
  methods: {
    onFileChange(e) {
      this.selectedFile = e.target.files[0];
      this.filename = this.selectedFile ? this.selectedFile.name : '';
      this.fileContent = '';
      this.parsedRows = [];
      this.message = '';
    },
    uploadFile() {
      if (!this.selectedFile) return;
      const reader = new FileReader();
      reader.onload = (e) => {
        this.fileContent = e.target.result;
        this.message = 'Archivo cargado en memoria. Listo para procesar.';
        this.success = true;
      };
      reader.onerror = () => {
        this.message = 'Error al leer el archivo.';
        this.success = false;
      };
      reader.readAsText(this.selectedFile);
    },
    parseFile() {
      if (!this.fileContent) return;
      // Simular el parseo del backend
      const lines = this.fileContent.split(/\r?\n/);
      const rows = [];
      for (let line of lines) {
        if (line.length < 155) continue;
        if (line.substr(3,4) !== '9999' && line.substr(153,1) !== 'B') {
          rows.push({
            sector: line.substr(0,1),
            categoria: line.substr(1,2),
            numero: line.substr(3,4),
            nombre: line.substr(7,30).trim(),
            telefono: line.substr(37,7).trim(),
            calle: line.substr(44,30).trim(),
            num: line.substr(74,4).trim(),
            cupo: line.substr(78,4).trim(),
            fec_alta: line.substr(82,2)+'/'+line.substr(84,2)+'/'+line.substr(86,2),
            fec_inic: line.substr(88,2)+'/'+line.substr(90,2)+'/'+line.substr(92,2),
            fec_venci: line.substr(94,2)+'/'+line.substr(96,2)+'/'+line.substr(98,2),
            de_las: line.substr(100,4).trim(),
            a_las: line.substr(104,4).trim(),
            de_las_dom: line.substr(108,4).trim(),
            a_las_dom: line.substr(112,4).trim(),
            lun: line.substr(116,1),
            mar: line.substr(117,1),
            mier: line.substr(118,1),
            jue: line.substr(119,1),
            vie: line.substr(120,1),
            sat: line.substr(121,1),
            dom: line.substr(122,1),
            pol_num: line.substr(123,12).trim(),
            pol_fec: line.substr(135,2)+'/'+line.substr(137,2)+'/'+line.substr(139,2),
            num_lic: line.substr(141,9).trim(),
            zona: line.substr(150,1),
            sub_zona: line.substr(151,2),
            estatus: line.substr(153,1),
            clave: line.substr(154,1)
          });
        }
      }
      this.parsedRows = rows;
      this.message = `Archivo procesado. Filas válidas: ${rows.length}`;
      this.success = true;
    },
    async insertRecords() {
      if (!this.parsedRows.length) return;
      this.message = 'Insertando registros...';
      this.success = false;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'sfrm_trans_pub.insert_records',
            payload: { records: this.parsedRows }
          })
        });
        const data = await response.json();
        this.message = data.eResponse.message;
        this.success = data.eResponse.success;
      } catch (e) {
        this.message = 'Error al insertar registros.';
        this.success = false;
      }
    },
    async updatePolFecVen() {
      if (!this.parsedRows.length) return;
      this.message = 'Actualizando fechas de póliza...';
      this.success = false;
      // Solo actualiza pol_fec_ven si existe pol_fec
      const updates = this.parsedRows.filter(r => r.pol_fec && r.pol_fec !== '00/00/00').map(r => ({
        sector: r.sector,
        categoria: r.categoria,
        numero: r.numero,
        pol_fec_ven: r.pol_fec
      }));
      if (!updates.length) {
        this.message = 'No hay fechas de póliza válidas para actualizar.';
        this.success = false;
        return;
      }
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'sfrm_trans_pub.update_pol_fec_ven',
            payload: { updates }
          })
        });
        const data = await response.json();
        this.message = data.eResponse.message;
        this.success = data.eResponse.success;
      } catch (e) {
        this.message = 'Error al actualizar fechas.';
        this.success = false;
      }
    }
  }
}
</script>

<style scoped>
.sfrm-trans-pub-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
}
</style>
