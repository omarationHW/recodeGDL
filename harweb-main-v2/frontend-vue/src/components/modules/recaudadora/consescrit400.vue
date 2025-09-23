<template>
  <div class="consescrit400-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Pagos AS400</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Consulta de Pagos AS400</h5>
      </div>
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-md-3">
            <label for="mpio">Municipio</label>
            <input type="number" class="form-control" id="mpio" v-model.number="form.mpio" @focus="onMpioEnter" @keyup.enter="focusNext('notario')" min="0">
          </div>
          <div class="col-md-3">
            <label for="notario">Notario</label>
            <input type="number" class="form-control" id="notario" v-model.number="form.notario" @keyup.enter="focusNext('escritura')" min="0">
          </div>
          <div class="col-md-3">
            <label for="escritura">Escritura</label>
            <input type="number" class="form-control" id="escritura" v-model.number="form.escritura" @keyup.enter="focusNext('buscar')" min="0">
          </div>
        </div>
        <div class="row mb-3">
          <div class="col-md-3">
            <label for="folio">Folio</label>
            <input type="number" class="form-control" id="folio" v-model.number="form.folio" @focus="onFolioEnter" @keyup.enter="focusNext('fecha')" min="0">
          </div>
          <div class="col-md-3">
            <label for="fecha">Fecha del folio</label>
            <input type="number" class="form-control" id="fecha" v-model.number="form.fecha" @keyup.enter="focusNext('buscar')" min="0">
          </div>
        </div>
        <div class="mb-3">
          <button ref="buscar" class="btn btn-success" @click="buscar">Buscar</button>
        </div>
        <div class="alert alert-info" v-if="infoMsg">
          {{ infoMsg }}
        </div>
        <div class="alert alert-danger" v-if="errorMsg">
          {{ errorMsg }}
        </div>
        <div v-if="resultados.length > 0">
          <h6>Escrituras registradas en As-400</h6>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead class="thead-light">
                <tr>
                  <th>Escritura</th>
                  <th>Notario</th>
                  <th>Municipio</th>
                  <th>Folio</th>
                  <th>Año Folio</th>
                  <th>Cuenta</th>
                  <th>Recaud</th>
                  <th>No Comp</th>
                  <th>Año Comp</th>
                  <th>Ccta</th>
                  <th>Crec</th>
                  <th>Clave</th>
                  <th>Capturista</th>
                  <th>Enviado</th>
                  <th>Regresado</th>
                  <th>Fecha</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultados" :key="idx">
                  <td>{{ row.escritura }}</td>
                  <td>{{ row.notario }}</td>
                  <td>{{ row.mpio }}</td>
                  <td>{{ row.folio }}</td>
                  <td>{{ row.axofolio }}</td>
                  <td>{{ row.cuenta }}</td>
                  <td>{{ row.recaud }}</td>
                  <td>{{ row.nocomp }}</td>
                  <td>{{ row.axocomp }}</td>
                  <td>{{ row.ccta }}</td>
                  <td>{{ row.crec }}</td>
                  <td>{{ row.clave }}</td>
                  <td>{{ row.capturista }}</td>
                  <td>{{ row.enviado }}</td>
                  <td>{{ row.regresado }}</td>
                  <td>{{ row.fecha }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div v-else-if="buscado">
          <div class="alert alert-warning">No se localizaron Escrituras del AS400</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsEscrit400Page',
  data() {
    return {
      form: {
        mpio: 0,
        notario: 0,
        escritura: 0,
        folio: 0,
        fecha: 0
      },
      resultados: [],
      infoMsg: '',
      errorMsg: '',
      buscado: false
    };
  },
  methods: {
    focusNext(ref) {
      if (ref === 'notario') {
        this.$el.querySelector('#notario').focus();
      } else if (ref === 'escritura') {
        this.$el.querySelector('#escritura').focus();
      } else if (ref === 'fecha') {
        this.$el.querySelector('#fecha').focus();
      } else if (ref === 'buscar') {
        this.$refs.buscar.focus();
      }
    },
    onFolioEnter() {
      this.form.mpio = 0;
      this.form.notario = 0;
      this.form.escritura = 0;
    },
    onMpioEnter() {
      this.form.folio = 0;
      this.form.fecha = 0;
    },
    async buscar() {
      this.infoMsg = '';
      this.errorMsg = '';
      this.resultados = [];
      this.buscado = false;
      // Validación mínima: al menos un criterio
      if (
        (this.form.mpio === 0 && this.form.notario === 0 && this.form.escritura === 0 && (this.form.folio === 0 || this.form.fecha === 0))
      ) {
        this.errorMsg = 'Debe ingresar Municipio/Notario/Escritura o Folio y Fecha.';
        return;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            action: 'consescrit400_search',
            params: {
              mpio: this.form.mpio,
              notario: this.form.notario,
              escritura: this.form.escritura,
              folio: this.form.folio,
              fecha: this.form.fecha
            }
          })
        });
        const data = await res.json();
        if (data.success && data.data && data.data.length > 0) {
          this.resultados = data.data;
          this.infoMsg = '';
        } else {
          this.resultados = [];
          this.infoMsg = '';
        }
        this.buscado = true;
      } catch (e) {
        this.errorMsg = 'Error al consultar: ' + (e.message || e);
      }
    }
  }
};
</script>

<style scoped>
.consescrit400-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
