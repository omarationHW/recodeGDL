<template>
  <div class="listados-page">
    <h1>Listados de Requerimientos</h1>
    <div class="breadcrumb">Inicio / Listados</div>
    <form @submit.prevent="buscarListados">
      <div class="form-row">
        <label>Aplicación:</label>
        <select v-model="form.modulo">
          <option v-for="(m, idx) in modulos" :key="idx" :value="m.value">{{ m.label }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Folio Desde:</label>
        <input type="number" v-model.number="form.folio_desde" min="1" required />
        <label>Folio Hasta:</label>
        <input type="number" v-model.number="form.folio_hasta" min="1" required />
      </div>
      <div class="form-row">
        <label>Recaudadora:</label>
        <select v-model="form.id_rec">
          <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Clave:</label>
        <select v-model="form.clave">
          <option value="todas">Todas</option>
          <option v-for="cve in claves" :key="cve.clave" :value="cve.clave">{{ cve.clave }} - {{ cve.descrip }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Vigencia:</label>
        <select v-model="form.vigencia">
          <option value="todas">Todas</option>
          <option v-for="vig in vigencias" :key="vig.clave" :value="vig.clave">{{ vig.clave }} - {{ vig.descrip }}</option>
        </select>
      </div>
      <div class="form-row" v-if="form.clave === 'P'">
        <label>Fecha Practicado Desde:</label>
        <input type="date" v-model="form.fecha_prac_desde" />
        <label>Hasta:</label>
        <input type="date" v-model="form.fecha_prac_hasta" />
      </div>
      <div class="form-actions">
        <button type="submit">Buscar</button>
        <button type="button" @click="exportarExcel" :disabled="!listados.length">Exportar Excel</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="listados.length">
      <h2>Resultados</h2>
      <table class="listados-table">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Fecha Emisión</th>
            <th>Clave Practicado</th>
            <th>Estado</th>
            <th>Nombre</th>
            <th>Datos</th>
            <th>Importe Pagado</th>
            <th>Recaudadora</th>
            <th>Zona</th>
            <th>Descripción</th>
            <th>Año Inicial</th>
            <th>Mes Inicial</th>
            <th>Año Final</th>
            <th>Mes Final</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in listados" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.fecha_emision }}</td>
            <td>{{ row.clave_practicado }}</td>
            <td>{{ row.estado }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.datos }}</td>
            <td>{{ row.imp_pagado }}</td>
            <td>{{ row.recaudadora_1 }}</td>
            <td>{{ row.zona_1 }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.axoini }}</td>
            <td>{{ row.mesini }}</td>
            <td>{{ row.axofin }}</td>
            <td>{{ row.mesfin }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListadosPage',
  data() {
    return {
      form: {
        id_rec: '',
        modulo: 11,
        folio_desde: 1,
        folio_hasta: 1,
        clave: 'todas',
        vigencia: 'todas',
        fecha_prac_desde: '',
        fecha_prac_hasta: ''
      },
      modulos: [
        { value: 11, label: 'Mercados' },
        { value: 16, label: 'Aseo' },
        { value: 24, label: 'Estacionamientos Públicos' },
        { value: 28, label: 'Estacionamientos Exclusivos' },
        { value: 14, label: 'Estacionómetros' },
        { value: 13, label: 'Cementerios' }
      ],
      claves: [],
      vigencias: [],
      recaudadoras: [],
      listados: [],
      loading: false,
      error: ''
    }
  },
  created() {
    this.cargarClaves();
    this.cargarVigencias();
    this.cargarRecaudadoras();
  },
  methods: {
    async cargarClaves() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getClaves' }
        });
        this.claves = res.data.eResponse.data;
      } catch (e) { this.error = 'Error cargando claves'; }
    },
    async cargarVigencias() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getVigencias' }
        });
        this.vigencias = res.data.eResponse.data;
      } catch (e) { this.error = 'Error cargando vigencias'; }
    },
    async cargarRecaudadoras() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getRecaudadoras' }
        });
        this.recaudadoras = res.data.eResponse.data;
        if (this.recaudadoras.length) this.form.id_rec = this.recaudadoras[0].id_rec;
      } catch (e) { this.error = 'Error cargando recaudadoras'; }
    },
    async buscarListados() {
      this.loading = true;
      this.error = '';
      this.listados = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getListados',
            params: { ...this.form }
          }
        });
        if (res.data.eResponse.success) {
          this.listados = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error consultando listados';
      }
      this.loading = false;
    },
    exportarExcel() {
      // Puede implementarse con una librería JS o backend
      alert('Funcionalidad de exportación a Excel no implementada en este demo.');
    }
  }
}
</script>

<style scoped>
.listados-page { max-width: 1200px; margin: 0 auto; padding: 2rem; }
.breadcrumb { font-size: 0.9rem; color: #888; margin-bottom: 1rem; }
.form-row { margin-bottom: 1rem; display: flex; align-items: center; }
.form-row label { width: 180px; font-weight: bold; }
.form-row input, .form-row select { flex: 1; margin-right: 1rem; }
.form-actions { margin-top: 1.5rem; }
.loading { color: #007bff; }
.error { color: #c00; font-weight: bold; }
.listados-table { width: 100%; border-collapse: collapse; margin-top: 2rem; }
.listados-table th, .listados-table td { border: 1px solid #ccc; padding: 0.5rem; }
.listados-table th { background: #f5f5f5; }
</style>
