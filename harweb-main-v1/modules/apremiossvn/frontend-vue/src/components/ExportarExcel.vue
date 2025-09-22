<template>
  <div class="exportar-excel-page">
    <h1>Exportar Estadísticas por Folio</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Exportar Excel</li>
      </ol>
    </nav>
    <form @submit.prevent="consultarFolios">
      <div class="row mb-3">
        <div class="col-md-3">
          <label>Aplicación</label>
          <select v-model="form.pmod" class="form-control">
            <option :value="11">Mercados</option>
            <option :value="16">Aseo Contratado</option>
            <option :value="14">Estacionómetros</option>
            <option :value="24">Estacionamientos Públicos</option>
            <option :value="28">Estacionamientos Exclusivos</option>
            <option :value="13">Cementerios</option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Folio Desde</label>
          <input type="number" v-model.number="form.pfold" min="1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Folio Hasta</label>
          <input type="number" v-model.number="form.pfolh" min="1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Recaudadora</label>
          <select v-model="form.prec" class="form-control">
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.id_rec }} - {{ rec.recaudadora }}
            </option>
          </select>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-md-3">
          <label>Fecha de Emisión</label>
          <input type="date" v-model="form.pfemi" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Fecha Pago Desde</label>
          <input type="date" v-model="form.pfpagd" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Fecha Pago Hasta</label>
          <input type="date" v-model="form.pfpagh" class="form-control" required />
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
        <div class="col-md-2">
          <button type="button" class="btn btn-success" @click="exportarExcel" :disabled="!folios.length">Exportar Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="folios.length">
      <table class="table table-bordered table-sm mt-3">
        <thead>
          <tr>
            <th>ID Control</th>
            <th>Módulo</th>
            <th>ID Módulo</th>
            <th>Folio</th>
            <th>Fecha Emisión</th>
            <th>Importe Pago</th>
            <th>Fecha Pago</th>
            <th>Periodo Inicial</th>
            <th>Periodo Final</th>
            <th>Registro</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="f in folios" :key="f.folio">
            <td>{{ f.idcontrol }}</td>
            <td>{{ f.moddulo }}</td>
            <td>{{ f.idmodulo }}</td>
            <td>{{ f.folio }}</td>
            <td>{{ f.fechaemision }}</td>
            <td>{{ f.importepago }}</td>
            <td>{{ f.fechapago }}</td>
            <td>{{ f.perinicial }}</td>
            <td>{{ f.perfinal }}</td>
            <td>{{ f.registro }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
import { saveAs } from 'file-saver';
import * as XLSX from 'xlsx';

export default {
  name: 'ExportarExcelPage',
  data() {
    return {
      recaudadoras: [],
      folios: [],
      loading: false,
      error: '',
      form: {
        prec: '',
        pmod: 11,
        pfold: 1,
        pfolh: 1,
        pfemi: '',
        pfpagd: '',
        pfpagh: ''
      }
    };
  },
  created() {
    this.cargarRecaudadoras();
    const today = new Date().toISOString().substr(0, 10);
    this.form.pfemi = today;
    this.form.pfpagd = today;
    this.form.pfpagh = today;
  },
  methods: {
    async cargarRecaudadoras() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'getRecaudadoras',
          params: {}
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length) {
            this.form.prec = this.recaudadoras[0].id_rec;
          }
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async consultarFolios() {
      this.error = '';
      this.loading = true;
      this.folios = [];
      try {
        const res = await axios.post('/api/execute', {
          action: 'getFoliosPagos',
          params: {
            prec: this.form.prec,
            pmod: this.form.pmod,
            pfold: this.form.pfold,
            pfolh: this.form.pfolh,
            pfemi: this.form.pfemi,
            pfpagd: this.form.pfpagd,
            pfpagh: this.form.pfpagh
          }
        });
        if (res.data.status === 'success') {
          this.folios = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    exportarExcel() {
      // Exportar los datos de folios a Excel usando SheetJS
      const ws = XLSX.utils.json_to_sheet(this.folios);
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, 'FoliosPagos');
      const wbout = XLSX.write(wb, { bookType: 'xlsx', type: 'array' });
      saveAs(new Blob([wbout], { type: 'application/octet-stream' }), 'FoliosPagos.xlsx');
    }
  }
};
</script>

<style scoped>
.exportar-excel-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
