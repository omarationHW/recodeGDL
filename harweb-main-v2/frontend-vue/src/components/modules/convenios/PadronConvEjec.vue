<template>
  <div class="padron-conv-ejec-page">
    <h1>Padron de Convenios por Ejecutor</h1>
    <div class="filters">
      <div class="row">
        <label>Tipo:</label>
        <select v-model="filters.tipo" @change="onTipoChange">
          <option v-for="t in tipos" :key="t.tipo" :value="t.tipo">{{ t.tipo }} - {{ t.descripcion }}</option>
        </select>
        <label>Subtipo:</label>
        <select v-model="filters.subtipo">
          <option value="000">000-TODOS LOS SUBTIPOS</option>
          <option v-for="s in subtipos" :key="s.subtipo" :value="s.subtipo">{{ s.subtipo }} - {{ s.desc_subtipo }}</option>
        </select>
        <label>Recaudadora:</label>
        <select v-model="filters.recaudadora">
          <option value="000">000-TODAS LAS RECAUDADORAS</option>
          <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec }} - {{ r.recaudadora }}</option>
        </select>
      </div>
      <div class="row">
        <label>Vigencia:</label>
        <select v-model="filters.vigencia">
          <option v-for="v in vigencias" :key="v.value" :value="v.value">{{ v.label }}</option>
        </select>
        <label>Ejecutor:</label>
        <select v-model="filters.ejecutor">
          <option value="000">000-TODOS LOS EJECUTORES</option>
          <option v-for="e in ejecutores" :key="e.cveejecutor" :value="e.cveejecutor">{{ e.cveejecutor }} - {{ e.ejecutor }}</option>
        </select>
        <label>Año inicio:</label>
        <input type="number" v-model.number="filters.anio_ini" min="2005" max="2099" style="width:80px" />
        <label>Año fin:</label>
        <input type="number" v-model.number="filters.anio_fin" min="2005" max="2099" style="width:80px" />
        <button @click="buscar">Buscar</button>
        <button @click="exportar">Exportar Excel</button>
      </div>
    </div>
    <div class="results">
      <h2>Resultados</h2>
      <table class="data-table">
        <thead>
          <tr>
            <th>IdConvenio</th>
            <th>Convenio</th>
            <th>Folio</th>
            <th>Ejecutor</th>
            <th>Fecha Practica</th>
            <th>Fecha Inicio</th>
            <th>Fecha Venc</th>
            <th>Pago Parcial</th>
            <th>Costo</th>
            <th>Pagos</th>
            <th>Adeudo</th>
            <th>Vigencia</th>
            <th>Vigencia Folio</th>
            <th>Fecha Pago</th>
            <th>Importe Pago</th>
            <th>Referencia</th>
            <th>Impuesto</th>
            <th>Recargos</th>
            <th>Gastos</th>
            <th>Multa</th>
            <th>Periodos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in resultados" :key="row.id_conv_resto">
            <td>{{ row.id_conv_resto }}</td>
            <td>{{ row.convenio }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.ejecutor }}</td>
            <td>{{ row.fprac }}</td>
            <td>{{ row.fecha_inicio }}</td>
            <td>{{ row.fecha_venc }}</td>
            <td>{{ row.pago_parcial }}</td>
            <td>{{ row.costo }}</td>
            <td>{{ row.pagos }}</td>
            <td>{{ row.adeudo }}</td>
            <td>{{ row.vigencia }}</td>
            <td>{{ row.vigfolio }}</td>
            <td>{{ row.fpago }}</td>
            <td>{{ row.importe_pago }}</td>
            <td>{{ row.referencia }}</td>
            <td>{{ row.impuesto }}</td>
            <td>{{ row.recargos }}</td>
            <td>{{ row.gastos }}</td>
            <td>{{ row.multa }}</td>
            <td>{{ row.periodos }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="resultados.length === 0">No hay resultados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PadronConvEjecPage',
  data() {
    return {
      tipos: [],
      subtipos: [],
      recaudadoras: [],
      ejecutores: [],
      vigencias: [],
      filtrosCargados: false,
      filters: {
        tipo: '',
        subtipo: '000',
        recaudadora: '000',
        vigencia: '0',
        ejecutor: '000',
        anio_ini: new Date().getFullYear(),
        anio_fin: new Date().getFullYear()
      },
      resultados: [],
      loading: false
    }
  },
  created() {
    this.initFilters();
  },
  methods: {
    async api(eRequest) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      });
      const json = await res.json();
      return json.eResponse;
    },
    async initFilters() {
      this.loading = true;
      const resp = await this.api({ action: 'init' });
      if (resp.success) {
        this.tipos = resp.data.tipos;
        this.recaudadoras = resp.data.recaudadoras;
        this.ejecutores = resp.data.ejecutores;
        this.vigencias = resp.data.vigencias;
        this.filters.tipo = this.tipos.length ? this.tipos[0].tipo : '';
        await this.onTipoChange();
        this.filtrosCargados = true;
      }
      this.loading = false;
    },
    async onTipoChange() {
      if (!this.filters.tipo) return;
      const resp = await this.api({ action: 'getSubtipos', tipo: this.filters.tipo });
      if (resp.success) {
        this.subtipos = resp.data;
        this.filters.subtipo = '000';
      }
    },
    async buscar() {
      this.loading = true;
      const resp = await this.api({
        action: 'list',
        tipo: this.filters.tipo,
        subtipo: this.filters.subtipo,
        recaudadora: this.filters.recaudadora,
        vigencia: this.filters.vigencia,
        ejecutor: this.filters.ejecutor,
        anio_ini: this.filters.anio_ini,
        anio_fin: this.filters.anio_fin
      });
      if (resp.success) {
        this.resultados = resp.data;
      } else {
        alert(resp.message);
      }
      this.loading = false;
    },
    async exportar() {
      this.loading = true;
      const resp = await this.api({
        action: 'export',
        tipo: this.filters.tipo,
        subtipo: this.filters.subtipo,
        recaudadora: this.filters.recaudadora,
        vigencia: this.filters.vigencia,
        ejecutor: this.filters.ejecutor,
        anio_ini: this.filters.anio_ini,
        anio_fin: this.filters.anio_fin
      });
      if (resp.success) {
        // Aquí se puede descargar el archivo Excel si se implementa en backend
        alert('Exportación completada.');
      } else {
        alert(resp.message);
      }
      this.loading = false;
    }
  }
}
</script>

<style scoped>
.padron-conv-ejec-page {
  padding: 24px;
}
.filters {
  background: #f9f9f9;
  padding: 16px;
  margin-bottom: 16px;
  border-radius: 8px;
}
.filters .row {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 8px;
}
.results {
  background: #fff;
  padding: 16px;
  border-radius: 8px;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 8px;
}
.data-table th, .data-table td {
  border: 1px solid #e0e0e0;
  padding: 4px 8px;
  font-size: 13px;
}
.data-table th {
  background: #f0f0f0;
}
</style>
