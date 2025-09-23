<template>
  <div class="multiple-nombre-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Múltiple por Nombre</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Buscar por Nombre</div>
      <div class="card-body">
        <form @submit.prevent="buscar">
          <div class="row mb-2">
            <div class="col-md-6">
              <label for="nombre">Nombre:</label>
              <input v-model="form.nombre" id="nombre" type="text" class="form-control" maxlength="60" required />
            </div>
            <div class="col-md-6">
              <label>Cementerios:</label>
              <div class="d-flex align-items-center">
                <div class="form-check me-2">
                  <input class="form-check-input" type="radio" id="todos" value="todos" v-model="form.cemOption" @change="onCemOptionChange">
                  <label class="form-check-label" for="todos">Todos</label>
                </div>
                <div class="form-check me-2">
                  <input class="form-check-input" type="radio" id="uno" value="uno" v-model="form.cemOption" @change="onCemOptionChange">
                  <label class="form-check-label" for="uno">Busca en</label>
                </div>
                <select v-if="form.cemOption==='uno'" v-model="form.cementerio" class="form-select ms-2" style="width: 120px;">
                  <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                    {{ cem.cementerio }} - {{ cem.nombre }}
                  </option>
                </select>
              </div>
            </div>
          </div>
          <div class="row mt-3">
            <div class="col">
              <button type="submit" class="btn btn-primary me-2"><i class="bi bi-search"></i> Buscar</button>
              <button type="button" class="btn btn-secondary" @click="limpiar">Limpiar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="resultados.length" class="card mb-3">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span>Resultados ({{ resultados.length }})</span>
        <button v-if="hasMore" class="btn btn-outline-info btn-sm" @click="continuarBusqueda">Continuar búsqueda</button>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-striped table-hover table-sm mb-0">
            <thead>
              <tr>
                <th>Nombre</th>
                <th>Folio</th>
                <th>Cementerio</th>
                <th>Clase</th>
                <th>Clase Alfa</th>
                <th>Sección</th>
                <th>Sección Alfa</th>
                <th>Línea</th>
                <th>Línea Alfa</th>
                <th>Fosa</th>
                <th>Fosa Alfa</th>
                <th>Año Pagado</th>
                <th>Metros</th>
                <th>Domicilio</th>
                <th>Exterior</th>
                <th>Interior</th>
                <th>Colonia</th>
                <th>Observaciones</th>
                <th>Usuario</th>
                <th>Fecha Mov</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in resultados" :key="row.control_rcm">
                <td>{{ row.nombre }}</td>
                <td>{{ row.control_rcm }}</td>
                <td>{{ row.cementerio }}</td>
                <td>{{ row.clase }}</td>
                <td>{{ row.clase_alfa }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.seccion_alfa }}</td>
                <td>{{ row.linea }}</td>
                <td>{{ row.linea_alfa }}</td>
                <td>{{ row.fosa }}</td>
                <td>{{ row.fosa_alfa }}</td>
                <td>{{ row.axo_pagado }}</td>
                <td>{{ row.metros }}</td>
                <td>{{ row.domicilio }}</td>
                <td>{{ row.exterior }}</td>
                <td>{{ row.interior }}</td>
                <td>{{ row.colonia }}</td>
                <td>{{ row.observaciones }}</td>
                <td>{{ row.usuario }}</td>
                <td>{{ row.fecha_mov ? (row.fecha_mov.substr(0,10)) : '' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div v-if="mensaje" class="alert alert-warning">{{ mensaje }}</div>
  </div>
</template>

<script>
export default {
  name: 'MultipleNombrePage',
  data() {
    return {
      form: {
        nombre: '',
        cemOption: 'todos',
        cementerio: '',
      },
      cementerios: [],
      resultados: [],
      mensaje: '',
      hasMore: false,
      lastControlRcm: 0,
      loading: false
    };
  },
  mounted() {
    this.cargarCementerios();
  },
  methods: {
    async cargarCementerios() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'cemeteriesList' }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.cementerios = data.eResponse.data;
        }
      } catch (e) {
        this.mensaje = 'Error al cargar cementerios';
      }
    },
    onCemOptionChange() {
      if (this.form.cemOption === 'uno' && this.cementerios.length) {
        this.form.cementerio = this.cementerios[0].cementerio;
      }
    },
    async buscar() {
      this.mensaje = '';
      this.resultados = [];
      this.hasMore = false;
      this.lastControlRcm = 0;
      this.loading = true;
      let cem1 = 'A', cem2 = 'Z';
      if (this.form.cemOption === 'uno' && this.form.cementerio) {
        cem1 = cem2 = this.form.cementerio;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'searchByName',
              params: {
                nombre: `%${this.form.nombre}%`,
                cuenta: 0,
                cem1,
                cem2,
                limit: 100
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.resultados = data.eResponse.data;
          this.hasMore = this.resultados.length === 100;
          if (this.resultados.length) {
            this.lastControlRcm = this.resultados[this.resultados.length - 1].control_rcm;
          }
          this.mensaje = data.eResponse.message;
        } else {
          this.mensaje = data.eResponse.message || 'No se encontraron resultados';
        }
      } catch (e) {
        this.mensaje = 'Error en la búsqueda';
      }
      this.loading = false;
    },
    async continuarBusqueda() {
      this.mensaje = '';
      this.loading = true;
      let cem1 = 'A', cem2 = 'Z';
      if (this.form.cemOption === 'uno' && this.form.cementerio) {
        cem1 = cem2 = this.form.cementerio;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'nextPageByName',
              params: {
                nombre: `%${this.form.nombre}%`,
                cuenta: this.lastControlRcm,
                cem1,
                cem2,
                limit: 100
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          const nuevos = data.eResponse.data;
          this.resultados = this.resultados.concat(nuevos);
          this.hasMore = nuevos.length === 100;
          if (nuevos.length) {
            this.lastControlRcm = nuevos[nuevos.length - 1].control_rcm;
          }
          this.mensaje = data.eResponse.message;
        } else {
          this.mensaje = data.eResponse.message || 'No hay más resultados';
        }
      } catch (e) {
        this.mensaje = 'Error al continuar búsqueda';
      }
      this.loading = false;
    },
    limpiar() {
      this.form.nombre = '';
      this.form.cemOption = 'todos';
      this.form.cementerio = '';
      this.resultados = [];
      this.mensaje = '';
      this.hasMore = false;
      this.lastControlRcm = 0;
    }
  }
}
</script>

<style scoped>
.multiple-nombre-page {
  max-width: 1200px;
  margin: 0 auto;
}
.table th, .table td {
  font-size: 0.95em;
}
</style>
