<template>
  <div class="reporte-anun-excel-page">
    <h1>Reporte de Anuncios</h1>
    <form @submit.prevent="consultar">
      <div class="form-row">
        <label>Tipo de Reporte:</label>
        <select v-model="form.tipoRep">
          <option :value="0">A la Fecha</option>
          <option :value="1">Rango de Fechas</option>
        </select>
      </div>
      <div class="form-row" v-if="form.tipoRep == 0">
        <label>Fecha de Consulta:</label>
        <input type="date" v-model="form.fechaCons" />
      </div>
      <div class="form-row" v-if="form.tipoRep == 1">
        <label>De:</label>
        <input type="date" v-model="form.fechaIni" />
        <label>Al:</label>
        <input type="date" v-model="form.fechaFin" />
      </div>
      <div class="form-row">
        <label>Vigencia:</label>
        <select v-model="form.vigencia">
          <option :value="0">Todas</option>
          <option :value="1">Vigentes (V)</option>
          <option :value="2">Canceladas (C/B)</option>
          <option :value="3">Estado 1 (A)</option>
        </select>
      </div>
      <div class="form-row">
        <label>Filtro de Adeudo:</label>
        <select v-model="form.adeudo">
          <option :value="0">Todos</option>
          <option :value="1">Sin Adeudo</option>
          <option :value="2">Con Adeudo desde</option>
          <option :value="3">Pagado por año desde</option>
          <option :value="4">Sin pago en</option>
          <option :value="5">Con adeudo al año</option>
          <option :value="6">Fecha de Pago</option>
        </select>
      </div>
      <div class="form-row" v-if="[2,3,4,5].includes(form.adeudo)">
        <label>Año:</label>
        <input type="number" v-model="form.axoIni" min="2000" max="2100" />
      </div>
      <div class="form-row" v-if="form.adeudo == 6">
        <label>Fecha Pago Inicio:</label>
        <input type="date" v-model="form.fechaPagoIni" />
        <label>Fecha Pago Fin:</label>
        <input type="date" v-model="form.fechaPagoFin" />
      </div>
      <div class="form-row">
        <label>Grupo de Anuncios:</label>
        <select v-model="form.grupoAnunId">
          <option :value="null">-- Todos --</option>
          <option v-for="g in gruposAnun" :key="g.id" :value="g.id">{{ g.descripcion }}</option>
        </select>
      </div>
      <div class="form-row">
        <button type="submit">Consultar</button>
        <button type="button" @click="exportarExcel" :disabled="loading">Exportar a Excel</button>
      </div>
    </form>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="resultados.length">
      <h2>Resultados</h2>
      <table class="resultados-table">
        <thead>
          <tr>
            <th>Anuncio</th>
            <th>Fecha Otorgamiento</th>
            <th>Propietario</th>
            <th>Licencia</th>
            <th>Empresa</th>
            <th>Tipo Anuncio</th>
            <th>Medidas1</th>
            <th>Medidas2</th>
            <th>Área</th>
            <th>Caras</th>
            <th>Ubicación</th>
            <th>NumExt</th>
            <th>LetraExt</th>
            <th>NumInt</th>
            <th>LetraInt</th>
            <th>Colonia</th>
            <th>CP</th>
            <th>Zona</th>
            <th>Subzona</th>
            <th>Vigente</th>
            <th>Bloqueado</th>
            <th>Fecha Baja</th>
            <th>Folio Baja</th>
            <th>Especificaciones</th>
            <th>Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in resultados" :key="r.anuncio">
            <td>{{ r.anuncio }}</td>
            <td>{{ r.fecha_otorgamiento }}</td>
            <td>{{ r.propietario }}</td>
            <td>{{ r.licencia }}</td>
            <td>{{ r.empresa }}</td>
            <td>{{ r.tipo_anuncio }}</td>
            <td>{{ r.medidas1 }}</td>
            <td>{{ r.medidas2 }}</td>
            <td>{{ r.area_anuncio }}</td>
            <td>{{ r.num_caras }}</td>
            <td>{{ r.ubicacion }}</td>
            <td>{{ r.numext_ubic }}</td>
            <td>{{ r.letraext_ubic }}</td>
            <td>{{ r.numint_ubic }}</td>
            <td>{{ r.letraint_ubic }}</td>
            <td>{{ r.colonia_ubic }}</td>
            <td>{{ r.cp }}</td>
            <td>{{ r.zona }}</td>
            <td>{{ r.subzona }}</td>
            <td>{{ r.vigente }}</td>
            <td>{{ r.bloqueado }}</td>
            <td>{{ r.fecha_baja }}</td>
            <td>{{ r.folio_baja }}</td>
            <td>{{ r.especificaciones }}</td>
            <td>{{ r.adeudo ?? '' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="excelUrl">
      <a :href="excelUrl" target="_blank">Descargar Excel</a>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReporteAnunExcelPage',
  data() {
    return {
      form: {
        tipoRep: 0,
        fechaCons: new Date().toISOString().substr(0,10),
        fechaIni: '',
        fechaFin: '',
        vigencia: 0,
        adeudo: 0,
        axoIni: new Date().getFullYear(),
        fechaPagoIni: '',
        fechaPagoFin: '',
        grupoAnunId: null
      },
      gruposAnun: [],
      resultados: [],
      loading: false,
      error: '',
      excelUrl: ''
    }
  },
  created() {
    this.cargarGruposAnun();
  },
  methods: {
    async cargarGruposAnun() {
      try {
        const eRequest = {
          action: 'licencias2.getGruposAnun',
          payload: {}
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.status === 'success') {
          this.gruposAnun = data.eResponse.data.result;
        }
      } catch (error) { this.error = error.message; }
    },
    async consultar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      this.excelUrl = '';
      try {
        const eRequest = {
          action: 'licencias2.getReporteAnuncios',
          payload: this.form
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.status === 'success') {
          this.resultados = data.eResponse.data.result;
        } else {
          this.error = data.message;
        }
      } catch (error) { this.error = error.message; }
      this.loading = false;
    },
    async exportarExcel() {
      this.loading = true;
      this.error = '';
      this.excelUrl = '';
      try {
        const eRequest = {
          action: 'licencias2.exportReporteAnuncios',
          payload: this.form
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.status === 'success') {
          this.excelUrl = data.eResponse.data.result.url;
        } else {
          this.error = data.message;
        }
      } catch (error) { this.error = error.message; }
      this.loading = false;
    }
  }
}
</script>

<style scoped>
.reporte-anun-excel-page { max-width: 1200px; margin: 0 auto; }
.form-row { margin-bottom: 1em; display: flex; align-items: center; gap: 1em; }
.resultados-table { width: 100%; border-collapse: collapse; }
.resultados-table th, .resultados-table td { border: 1px solid #ccc; padding: 4px; }
.error { color: red; }
</style>
