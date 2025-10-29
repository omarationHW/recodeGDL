<template>
  <div class="list-mov-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Movimientos de Cementerios</li>
      </ol>
    </nav>
    <h2>Listado de Movimientos de Cementerios</h2>
    <form @submit.prevent="fetchMovements">
      <div class="row mb-3">
        <div class="col-md-4">
          <label for="fecha1" class="form-label"><strong>Fecha Desde</strong></label>
          <input type="date" v-model="form.fecha1" id="fecha1" class="form-control" required>
        </div>
        <div class="col-md-4">
          <label for="fecha2" class="form-label"><strong>Fecha Hasta</strong></label>
          <input type="date" v-model="form.fecha2" id="fecha2" class="form-control" required>
        </div>
        <div class="col-md-4" v-if="showRecaudadora">
          <label for="reca" class="form-label"><strong>Recaudadora</strong></label>
          <input type="number" v-model.number="form.reca" id="reca" class="form-control" min="1" max="9" required>
        </div>
      </div>
      <div class="mb-3">
        <button type="submit" class="btn btn-primary me-2">Procesar</button>
        <button type="button" class="btn btn-secondary" @click="resetForm">Limpiar</button>
        <button type="button" class="btn btn-success ms-2" @click="printReport" :disabled="movements.length === 0">Imprimir Reporte</button>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="movements.length > 0">
      <h4>Resultados</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Reg. Mun. Cem.</th>
            <th>Metros</th>
            <th>UAPAG.</th>
            <th>Nombre</th>
            <th>Colonia</th>
            <th>Observaciones</th>
            <th>Fecha Actual</th>
            <th>Usuario</th>
            <th>Llave</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="mov in movements" :key="mov.control_rcm">
            <td>{{ mov.control_rcm }}</td>
            <td>{{ mov.cementerio }}</td>
            <td>{{ mov.metros }}</td>
            <td>{{ mov.axo_pagado }}</td>
            <td>{{ mov.nombre }}</td>
            <td>{{ mov.colonia }}</td>
            <td>{{ mov.observaciones }}</td>
            <td>{{ mov.fecha_mov }}</td>
            <td>{{ mov.nombre_1 }}</td>
            <td>{{ mov.llave }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="reportMessage" class="alert alert-success mt-3">{{ reportMessage }}</div>
  </div>
</template>

<script>
export default {
  name: 'ListMovPage',
  data() {
    return {
      form: {
        fecha1: '',
        fecha2: '',
        reca: 1
      },
      showRecaudadora: false, // Cambiar según lógica de usuario
      movements: [],
      loading: false,
      error: '',
      reportMessage: ''
    };
  },
  created() {
    // Aquí podrías cargar si el usuario debe ver el campo recaudadora
    // this.showRecaudadora = (this.$store.state.user.id_usuario === 2)
  },
  methods: {
    async fetchMovements() {
      this.loading = true;
      this.error = '';
      this.reportMessage = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            action: 'list_movements',
            params: {
              fecha1: this.form.fecha1,
              fecha2: this.form.fecha2,
              reca: this.form.reca
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.movements = data.data;
        } else {
          this.error = data.message || 'Error al consultar movimientos';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      } finally {
        this.loading = false;
      }
    },
    resetForm() {
      this.form.fecha1 = '';
      this.form.fecha2 = '';
      this.form.reca = 1;
      this.movements = [];
      this.error = '';
      this.reportMessage = '';
    },
    async printReport() {
      this.loading = true;
      this.error = '';
      this.reportMessage = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            action: 'print_report',
            params: {
              fecha1: this.form.fecha1,
              fecha2: this.form.fecha2,
              reca: this.form.reca
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          // Aquí podrías abrir un PDF o mostrar mensaje
          this.reportMessage = data.message || 'Reporte generado';
        } else {
          this.error = data.message || 'Error al generar reporte';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.list-mov-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
