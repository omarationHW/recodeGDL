<template>
  <div class="module-view">
    <h1>Generar Adeudos Tianguis (Mercado 214)</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Paso Adeudos
    </div>
    <form @submit.prevent="generarAdeudos">
      <div class="form-row">
        <label class="municipal-form-label" for="trimestre">Trimestre:</label>
        <select v-model="trimestre" id="trimestre">
          <option v-for="t in [1,2,3,4]" :key="t" :value="t">{{ t }}</option>
        </select>
        <label class="municipal-form-label" for="ano">Año:</label>
        <input type="number" v-model="ano" id="ano" min="2009" max="2999" />
        <button type="submit">Generar Adeudos</button>
      </div>
    </form>
    <div v-if="adeudos.length">
      <h2>Previsualización de Adeudos</h2>
      <table class="-bordered municipal-table-sm">
        <thead>
          <tr>
            <th>#</th>
            <th>Id Local</th>
            <th>Año</th>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Actualización</th>
            <th>Id Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="row.id_local">
            <td>{{ row.registro }}</td>
            <td>{{ row.id_local }}</td>
            <td>{{ row.ano }}</td>
            <td>{{ row.periodo }}</td>
            <td>{{ row.importe.toFixed(2) }}</td>
            <td>{{ formatDate(row.actualizacion) }}</td>
            <td>{{ row.id_usuario }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="insertarAdeudos" :disabled="loading">Insertar Adeudos</button>
    </div>
    <div v-if="loading" class="alert alert-info mt-3">Procesando...</div>
    <div v-if="message" class="alert alert-success mt-3">{{ message }}</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'PasoAdeudosPage',
  data() {
    return {
      trimestre: 1,
      ano: new Date().getFullYear(),
      adeudos: [],
      loading: false,
      message: '',
      error: ''
    }
  },
  methods: {
    async generarAdeudos() {
      this.loading = true;
      this.message = '';
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: {
            action: 'generarAdeudos',
            params: {
              trimestre: this.trimestre,
              ano: this.ano,
              usuario_id: this.$store.state.user.id || 1
            }
          }
        }
          )
        });
        const resData = await res.json();
        if (resData.eResponse.status === 'ok') {
          this.adeudos = resData.eResponse.data;
        } else {
          this.error = resData.eResponse.message || 'Error generando adeudos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async insertarAdeudos() {
      this.loading = true;
      this.message = '';
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: {
            action: 'insertarAdeudos',
            params: {
              adeudos: this.adeudos
            }
          }
        }
          )
        });
        const resData = await res.json();
        if (resData.eResponse.status === 'ok') {
          this.message = `Adeudos insertados correctamente: ${resData.eResponse.data.insertados}`;
          this.adeudos = [];
        } else {
          this.error = resData.eResponse.message || 'Error insertando adeudos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    formatDate(dt) {
      if (!dt) return '';
      const d = new Date(dt);
      return d.toLocaleString();
    }
  }
}
</script>

<style scoped>
.container.paso-adeudos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.table {
  margin-top: 1rem;
}
</style>
