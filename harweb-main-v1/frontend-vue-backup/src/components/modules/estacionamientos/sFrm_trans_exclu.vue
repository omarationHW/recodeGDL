<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Transferencia de Exclusivos</li>
      </ol>
    </nav>
    <h2>Transferencia de datos del HP3000 a PostgreSQL</h2>
    <h4>de estacionamientos públicos</h4>
    <div class="card mt-3">
      <div class="card-body">
        <div class="mb-3">
          <label for="fileInput" class="form-label">Seleccionar archivo plano</label>
          <input type="file" class="form-control" id="fileInput" @change="onFileChange" accept=".txt,.dat" />
        </div>
        <div v-if="fileName" class="mb-2">
          <strong>Archivo seleccionado:</strong> {{ fileName }}
        </div>
        <button class="btn btn-primary me-2" :disabled="!fileContent" @click="parseFile">Pasar Datos</button>
        <button class="btn btn-success me-2" :disabled="parsedRows.length === 0" @click="importRows">Altas</button>
        <button class="btn btn-warning" @click="showUpdateModal = true">Actualizar Fechas</button>
      </div>
    </div>
    <div v-if="parsedRows.length > 0" class="mt-4">
      <h5>Vista previa de registros parseados</h5>
      <div class="table-responsive" style="max-height: 350px; overflow-y: auto;">
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th v-for="col in columns" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in parsedRows" :key="idx">
              <td v-for="col in columns" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <!-- Modal para actualizar fechas -->
    <div v-if="showUpdateModal" class="modal fade show d-block" tabindex="-1" style="background:rgba(0,0,0,0.3);">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Actualizar Fecha de Vencimiento</h5>
            <button type="button" class="btn-close" @click="showUpdateModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="mb-2">
              <label>Sector</label>
              <input v-model="updateForm.sector" class="form-control" />
            </div>
            <div class="mb-2">
              <label>Categoría</label>
              <input v-model="updateForm.categ" class="form-control" />
            </div>
            <div class="mb-2">
              <label>Número</label>
              <input v-model="updateForm.num" class="form-control" type="number" />
            </div>
            <div class="mb-2">
              <label>Fecha Vencimiento</label>
              <input v-model="updateForm.fec_venci" class="form-control" type="date" />
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="showUpdateModal = false">Cancelar</button>
            <button class="btn btn-primary" @click="updateFechaVenci">Actualizar</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'TransExcluPage',
  data() {
    return {
      fileName: '',
      fileContent: '',
      parsedRows: [],
      columns: [
        'CVE_SECTOR','CVE_ZONA','CVE_METROS','CVE_TIPO','CVE_NUMERO','NOMBRE','TELEFONO','CALLE','NUM','DOMFIS','FECHA_ALTA','FECHA_INIC','FECHA_VENCI','NUMOFT','NUMOFM','NUMCTAT','ZOPPARQ','MANZ','ESTATUS','CLAVE'
      ],
      message: '',
      success: true,
      showUpdateModal: false,
      updateForm: {
        sector: '',
        categ: '',
        num: '',
        fec_venci: ''
      }
    }
  },
  methods: {
    onFileChange(e) {
      const file = e.target.files[0];
      if (!file) return;
      this.fileName = file.name;
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.fileContent = evt.target.result;
        this.parsedRows = [];
        this.message = '';
      };
      reader.readAsText(file);
    },
    async parseFile() {
      this.message = '';
      if (!this.fileContent) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'import_exclusivo_file',
              payload: { file_content: this.fileContent }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.parsedRows = data.eResponse.data;
          this.success = true;
          this.message = 'Archivo parseado correctamente.';
        } else {
          this.success = false;
          this.message = data.eResponse.message;
        }
      } catch (err) {
        this.success = false;
        this.message = 'Error al parsear archivo.';
      }
    },
    async importRows() {
      this.message = '';
      let ok = 0, fail = 0;
      for (const row of this.parsedRows) {
        try {
          const res = await fetch('/api/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              eRequest: {
                action: 'insert_exclusivo_row',
                payload: row
              }
            })
          });
          const data = await res.json();
          if (data.eResponse.success) ok++;
          else fail++;
        } catch (e) {
          fail++;
        }
      }
      this.success = fail === 0;
      this.message = `Importación finalizada. Éxito: ${ok}, Fallos: ${fail}`;
    },
    async updateFechaVenci() {
      this.message = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'update_publicos_fecha_venci',
              payload: this.updateForm
            }
          })
        });
        const data = await res.json();
        this.success = data.eResponse.success;
        this.message = data.eResponse.message;
        if (data.eResponse.success) this.showUpdateModal = false;
      } catch (e) {
        this.success = false;
        this.message = 'Error al actualizar fecha.';
      }
    }
  }
}
</script>

<style scoped>
.table-responsive {
  max-height: 350px;
}
.modal {
  display: block;
}
</style>
