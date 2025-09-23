<template>
  <div class="contratos-estadistico-page">
    <h1>Estadístico de Contratos</h1>
    <form @submit.prevent="onEjecutar">
      <div class="filters">
        <div>
          <label>Vigencia de Contratos</label>
          <select v-model="form.vigencia">
            <option v-for="v in filters.vigencias" :key="v.value" :value="v.value">{{ v.label }}</option>
          </select>
        </div>
        <div>
          <label>Ofna. Recaudadora</label>
          <select v-model="form.oficina">
            <option value="0">Todas</option>
            <option v-for="o in filters.oficinas" :key="o.value" :value="o.value">{{ o.label }}</option>
          </select>
        </div>
        <div>
          <label>Tipo de Aseo</label>
          <select v-model="form.tipo_aseo">
            <option value="999">Todos los tipos</option>
            <option v-for="t in filters.tipos_aseo" :key="t.value" :value="t.value">{{ t.label }}</option>
          </select>
        </div>
      </div>
      <div class="filters">
        <div>
          <label>Visualización de Adeudos</label>
          <select v-model="form.adeudos_visual">
            <option v-for="v in filters.adeudos_visual" :key="v.value" :value="v.value">{{ v.label }}</option>
          </select>
        </div>
        <div>
          <label>Vigencia de Adeudos</label>
          <select v-model="form.vig_adeudos">
            <option v-for="v in filters.vigencias_adeudos" :key="v.value" :value="v.value">{{ v.label }}</option>
          </select>
        </div>
        <div>
          <label>Grupo de Adeudos</label>
          <select v-model="form.grupo_adeudos" @change="onGrupoAdeudosChange">
            <option v-for="g in filters.grupo_adeudos" :key="g.value" :value="g.value">{{ g.label }}</option>
          </select>
        </div>
      </div>
      <div v-if="form.grupo_adeudos === 0" class="periodo-mes">
        <label>Periodo de Adeudo</label>
        <div>
          <input v-model="form.periodo_inicio_aso" type="number" min="1900" max="2100" style="width:70px" placeholder="Año Inicio" />
          <select v-model="form.periodo_inicio_mes">
            <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
          </select>
          <span>al</span>
          <input v-model="form.periodo_fin_aso" type="number" min="1900" max="2100" style="width:70px" placeholder="Año Fin" />
          <select v-model="form.periodo_fin_mes">
            <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
          </select>
        </div>
      </div>
      <div v-if="form.grupo_adeudos === 1" class="periodo-fecha">
        <label>Periodo de Pago</label>
        <div>
          <input v-model="form.fecha_inicio" type="date" />
          <span>al</span>
          <input v-model="form.fecha_fin" type="date" />
        </div>
      </div>
      <div class="actions">
        <button type="submit">Ejecutar</button>
        <button type="button" @click="onCancelar">Cancelar</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="result && result.length">
      <h2>Resultados</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Tipo de Aseo</th>
            <th>Contratos Totales</th>
            <th>Vigentes</th>
            <th>Cancelados</th>
            <th>Adeudos Totales</th>
            <th>Adeudos Vigentes</th>
            <th>Adeudos Cancelados</th>
            <th>Adeudos Pagados</th>
            <th>Adeudos Suspendidos</th>
            <!-- ... más columnas según el reporte ... -->
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in result" :key="row.tipo_aseo">
            <td>{{ row.tipo_aseo }}</td>
            <td>{{ row.contratos_totales }}</td>
            <td>{{ row.contratos_vigentes }}</td>
            <td>{{ row.contratos_cancelados }}</td>
            <td>{{ row.adeudos_totales }}</td>
            <td>{{ row.adeudos_vigentes }}</td>
            <td>{{ row.adeudos_cancelados }}</td>
            <td>{{ row.adeudos_pagados }}</td>
            <td>{{ row.adeudos_suspendidos }}</td>
            <!-- ... -->
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContratosEstadisticoPage',
  data() {
    return {
      filters: {
        vigencias: [],
        oficinas: [],
        tipos_aseo: [],
        vigencias_adeudos: [],
        grupo_adeudos: [],
        adeudos_visual: []
      },
      meses: ['01','02','03','04','05','06','07','08','09','10','11','12'],
      form: {
        vigencia: 'T',
        oficina: 0,
        tipo_aseo: 999,
        vig_adeudos: 'T',
        grupo_adeudos: 0,
        periodo_inicio_aso: '',
        periodo_inicio_mes: '01',
        periodo_fin_aso: '',
        periodo_fin_mes: '01',
        fecha_inicio: '',
        fecha_fin: '',
        adeudos_visual: 0
      },
      loading: false,
      error: '',
      result: []
    }
  },
  created() {
    this.fetchFilters();
    const now = new Date();
    this.form.periodo_inicio_aso = now.getFullYear();
    this.form.periodo_fin_aso = now.getFullYear();
    this.form.periodo_inicio_mes = (now.getMonth()+1).toString().padStart(2,'0');
    this.form.periodo_fin_mes = (now.getMonth()+1).toString().padStart(2,'0');
  },
  methods: {
    fetchFilters() {
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getFilters' })
      })
      .then(res => res.json())
      .then(data => {
        this.filters = data.data;
        this.loading = false;
      })
      .catch(err => {
        this.error = 'Error cargando filtros';
        this.loading = false;
      });
    },
    onGrupoAdeudosChange() {
      // Limpiar campos de periodo/fecha según selección
      if (this.form.grupo_adeudos === 0) {
        this.form.fecha_inicio = '';
        this.form.fecha_fin = '';
      } else if (this.form.grupo_adeudos === 1) {
        this.form.periodo_inicio_aso = '';
        this.form.periodo_fin_aso = '';
      }
    },
    onEjecutar() {
      this.loading = true;
      this.error = '';
      // Construir parámetros
      let params = {
        vigencia: this.form.vigencia,
        oficina: this.form.oficina,
        tipo_aseo: this.form.tipo_aseo,
        vig_adeudos: this.form.vig_adeudos,
        grupo_adeudos: this.form.grupo_adeudos,
        periodo_inicio: this.form.periodo_inicio_aso + '-' + this.form.periodo_inicio_mes,
        periodo_fin: this.form.periodo_fin_aso + '-' + this.form.periodo_fin_mes,
        fecha_inicio: this.form.fecha_inicio,
        fecha_fin: this.form.fecha_fin,
        adeudos_visual: this.form.adeudos_visual
      };
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getEstadistico', params })
      })
      .then(res => res.json())
      .then(data => {
        if (data.success) {
          this.result = data.data;
        } else {
          this.error = data.message || 'Error en la consulta';
        }
        this.loading = false;
      })
      .catch(err => {
        this.error = 'Error ejecutando consulta';
        this.loading = false;
      });
    },
    onCancelar() {
      this.result = [];
      this.error = '';
    }
  }
}
</script>

<style scoped>
.contratos-estadistico-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.filters {
  display: flex;
  gap: 2rem;
  margin-bottom: 1rem;
}
.actions {
  margin-top: 1rem;
}
.result-table {
  width: 100%;
  border-collapse: collapse;
}
.result-table th, .result-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.loading { color: #007bff; }
.error { color: #c00; }
</style>
