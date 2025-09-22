<template>
  <div class="ejercicios-ins-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Ejercicios</li>
      </ol>
    </nav>
    <h2>Gestión de Ejercicios</h2>
    <div class="card mb-4">
      <div class="card-header">Ejercicios Existentes</div>
      <div class="card-body">
        <table class="table table-striped">
          <thead>
            <tr>
              <th>#</th>
              <th>Ejercicio</th>
              <th>Fecha de Alta</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(ej, idx) in ejercicios" :key="ej.ejercicio">
              <td>{{ idx + 1 }}</td>
              <td>{{ ej.ejercicio }}</td>
              <td>{{ formatDate(ej.fecha_hora_alta) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div class="card">
      <div class="card-header">Agregar Nuevo Ejercicio</div>
      <div class="card-body">
        <form @submit.prevent="crearEjercicio">
          <div class="form-group">
            <label for="nuevoEjercicio">Nuevo Ejercicio</label>
            <input type="number" v-model="nuevoEjercicio" id="nuevoEjercicio" class="form-control" min="1900" max="2100" required />
          </div>
          <button type="submit" class="btn btn-primary">Aceptar</button>
        </form>
        <div v-if="mensaje" :class="{'alert': true, 'alert-success': exito, 'alert-danger': !exito}" class="mt-3">
          {{ mensaje }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EjerciciosInsPage',
  data() {
    return {
      ejercicios: [],
      nuevoEjercicio: '',
      mensaje: '',
      exito: false
    };
  },
  created() {
    this.cargarEjercicios();
  },
  methods: {
    cargarEjercicios() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'get_ejercicios' })
      })
        .then(res => res.json())
        .then(res => {
          if (res.success) {
            this.ejercicios = res.data;
          } else {
            this.mensaje = res.message;
            this.exito = false;
          }
        });
    },
    crearEjercicio() {
      if (!this.nuevoEjercicio) {
        this.mensaje = 'Debe ingresar el año del ejercicio';
        this.exito = false;
        return;
      }
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'create_ejercicio',
          params: { ejercicio: parseInt(this.nuevoEjercicio) }
        })
      })
        .then(res => res.json())
        .then(res => {
          this.mensaje = res.message;
          this.exito = res.success;
          if (res.success) {
            this.cargarEjercicios();
            this.nuevoEjercicio = '';
          }
        });
    },
    formatDate(dt) {
      if (!dt) return '';
      return new Date(dt).toLocaleString();
    }
  }
};
</script>

<style scoped>
.ejercicios-ins-page {
  max-width: 700px;
  margin: 0 auto;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
