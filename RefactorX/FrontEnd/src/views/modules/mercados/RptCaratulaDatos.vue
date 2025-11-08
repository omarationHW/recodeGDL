<template>
  <div class="rpt-caratula-datos-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Carátula de Locales</span>
    </nav>
    <h1>Carátula de Locales</h1>
    <form @submit.prevent="fetchCaratulaDatos">
      <div class="form-row">
        <label for="id_local">ID Local:</label>
        <input v-model="form.id_local" id="id_local" type="number" required />
      </div>
      <div class="form-row">
        <label for="renta">Renta:</label>
        <input v-model="form.renta" id="renta" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label for="adeudo">Adeudo:</label>
        <input v-model="form.adeudo" id="adeudo" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label for="recargos">Recargos:</label>
        <input v-model="form.recargos" id="recargos" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label for="gastos">Gastos:</label>
        <input v-model="form.gastos" id="gastos" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label for="multa">Multa:</label>
        <input v-model="form.multa" id="multa" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label for="total">Total:</label>
        <input v-model="form.total" id="total" type="number" step="0.01" required />
      </div>
      <div class="form-row">
        <label for="folios">Folios Requerimientos:</label>
        <input v-model="form.folios" id="folios" type="text" />
      </div>
      <div class="form-row">
        <label for="leyenda">Leyenda:</label>
        <input v-model="form.leyenda" id="leyenda" type="text" />
      </div>
      <button type="submit">Consultar Carátula</button>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="result">
      <h2>Datos del Local</h2>
      <table class="result-table">
        <tr><th>Nombre</th><td>{{ result.nombre }}</td></tr>
        <tr><th>Domicilio</th><td>{{ result.domicilio }}</td></tr>
        <tr><th>Sector</th><td>{{ result.sector }}</td></tr>
        <tr><th>Zona</th><td>{{ result.zona }}</td></tr>
        <tr><th>Descripción</th><td>{{ result.descripcion_local }}</td></tr>
        <tr><th>Superficie</th><td>{{ result.superficie }}</td></tr>
        <tr><th>Giro</th><td>{{ result.giro }}</td></tr>
        <tr><th>Fecha Alta</th><td>{{ result.fecha_alta }}</td></tr>
        <tr><th>Vigencia</th><td>{{ result.vigdescripcion }}</td></tr>
        <tr><th>Usuario</th><td>{{ result.usuario }}</td></tr>
        <tr><th>Renta</th><td>{{ result.renta }}</td></tr>
        <tr><th>Adeudo</th><td>{{ result.adeudo }}</td></tr>
        <tr><th>Recargos</th><td>{{ result.recargos }}</td></tr>
        <tr><th>Gastos</th><td>{{ result.gastos }}</td></tr>
        <tr><th>Multa</th><td>{{ result.multa }}</td></tr>
        <tr><th>Total</th><td>{{ result.total }}</td></tr>
        <tr><th>Folios Requerimientos</th><td>{{ result.folios }}</td></tr>
        <tr><th>Leyenda</th><td>{{ result.leyenda }}</td></tr>
      </table>
      <h2>Detalle de Adeudos</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Adeudo</th>
            <th>Recargos</th>
            <th>Leyenda</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="adeudo in result.adeudos" :key="adeudo.percadena">
            <td>{{ adeudo.percadena }}</td>
            <td>{{ adeudo.impcalc }}</td>
            <td>{{ adeudo.recargos }}</td>
            <td>{{ adeudo.leyenda }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptCaratulaDatosPage',
  data() {
    return {
      form: {
        id_local: '',
        renta: '',
        adeudo: '',
        recargos: '',
        gastos: '',
        multa: '',
        total: '',
        folios: '',
        leyenda: ''
      },
      loading: false,
      error: '',
      result: null
    }
  },
  methods: {
    async fetchCaratulaDatos() {
      this.loading = true;
      this.error = '';
      this.result = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getRptCaratulaDatos',
            params: { ...this.form }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.result = data.data && data.data[0] ? data.data[0] : null;
        } else {
          this.error = data.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.rpt-caratula-datos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.form-row input {
  flex: 1;
  padding: 0.3rem;
}
.result-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.result-table th, .result-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.loading { color: #007bff; }
.error { color: #c00; }
</style>
