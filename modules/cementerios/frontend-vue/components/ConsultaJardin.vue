<template>
  <div class="consulta-jardin-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Cementerio Jardín</li>
      </ol>
    </nav>
    <h1>Consultas a la base de Datos de Cementerio Jardín</h1>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="onConsultar">
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" id="rcm" value="rcm" v-model="modoBusqueda">
            <label class="form-check-label" for="rcm">Consulta por RCM</label>
          </div>
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" id="nombre" value="nombre" v-model="modoBusqueda">
            <label class="form-check-label" for="nombre">Consulta por NOMBRE</label>
          </div>
          <div class="form-check form-check-inline">
            <input class="form-check-input" type="radio" id="partida" value="partida" v-model="modoBusqueda">
            <label class="form-check-label" for="partida">Consulta por PARTIDA</label>
          </div>

          <div v-if="modoBusqueda === 'rcm'" class="row mt-3">
            <div class="col-md-2">
              <label for="clase">Clase</label>
              <input type="number" min="1" max="3" class="form-control" v-model.number="form.vclase" id="clase" required>
            </div>
            <div class="col-md-2">
              <label for="seccion">Sección</label>
              <input type="number" min="1" class="form-control" v-model.number="form.vsec" id="seccion" required>
            </div>
            <div class="col-md-2">
              <label for="linea">Línea</label>
              <input type="number" min="1" class="form-control" v-model.number="form.vlinea" id="linea" required>
            </div>
          </div>

          <div v-if="modoBusqueda === 'nombre'" class="row mt-3">
            <div class="col-md-6">
              <label for="nombre">Nombre</label>
              <input type="text" class="form-control" v-model="form.nombre" id="nombre" maxlength="70" required>
            </div>
          </div>

          <div v-if="modoBusqueda === 'partida'" class="row mt-3">
            <div class="col-md-6">
              <label for="ppago">Partida de Pago</label>
              <input type="text" class="form-control" v-model="form.ppago" id="ppago" maxlength="15" required>
            </div>
          </div>

          <div class="mt-3">
            <button type="submit" class="btn btn-primary">Consultar</button>
            <button type="button" class="btn btn-secondary ml-2" @click="onLimpiar">Limpiar</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="loading" class="alert alert-info">Consultando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="resultados.length > 0" class="table-responsive">
      <table class="table table-bordered table-hover">
        <thead>
          <tr>
            <th>Clase</th>
            <th>Sección</th>
            <th>Línea</th>
            <th>Fosa</th>
            <th>Partida Pago</th>
            <th>Nombre</th>
            <th>Fecha Compra</th>
            <th>Otros</th>
            <th>Clave</th>
            <th>Medida</th>
            <th>Calle</th>
            <th>Colonia</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in resultados" :key="idx">
            <td>{{ row.clase }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.linea }}</td>
            <td>{{ row.fosa }}</td>
            <td>{{ row.ppago }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.fcompra ? (new Date(row.fcompra)).toLocaleDateString() : '' }}</td>
            <td>{{ row.otros }}</td>
            <td>{{ row.clave }}</td>
            <td>{{ row.medida }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.colonia }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && resultados.length === 0 && consultaRealizada" class="alert alert-warning">
      No se encontraron resultados para la consulta.
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaJardin',
  data() {
    return {
      modoBusqueda: 'rcm',
      form: {
        vclase: 1,
        vsec: 1,
        vlinea: 1,
        nombre: '',
        ppago: ''
      },
      resultados: [],
      loading: false,
      error: '',
      consultaRealizada: false
    };
  },
  methods: {
    async onConsultar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      this.consultaRealizada = false;
      let action = '';
      let params = {};
      if (this.modoBusqueda === 'rcm') {
        action = 'consulta_jardin_by_rcm';
        params = {
          vclase: this.form.vclase,
          vsec: this.form.vsec,
          vlinea: this.form.vlinea
        };
      } else if (this.modoBusqueda === 'nombre') {
        action = 'consulta_jardin_by_nombre';
        params = {
          nombre: this.form.nombre
        };
      } else if (this.modoBusqueda === 'partida') {
        action = 'consulta_jardin_by_partida';
        params = {
          ppago: this.form.ppago
        };
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ action, params })
        });
        const data = await res.json();
        if (data.success) {
          this.resultados = data.data || [];
        } else {
          this.error = data.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
        this.consultaRealizada = true;
      }
    },
    onLimpiar() {
      this.form = {
        vclase: 1,
        vsec: 1,
        vlinea: 1,
        nombre: '',
        ppago: ''
      };
      this.resultados = [];
      this.error = '';
      this.consultaRealizada = false;
    }
  }
};
</script>

<style scoped>
.consulta-jardin-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
.card {
  border: 1px solid #e3e3e3;
}
</style>
