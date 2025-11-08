<template>
  <div class="listanotificaciones-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Notificaciones</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        Listado de actas notificadas
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="reca" class="form-label"><b>Recaudadora</b></label>
              <input type="number" v-model.number="form.reca" id="reca" class="form-control" required @keyup.enter="focusNext('axo')">
            </div>
            <div class="col-md-3">
              <label for="axo" class="form-label"><b>Año</b></label>
              <input type="number" v-model.number="form.axo" id="axo" class="form-control" required @keyup.enter="focusNext('inicio')">
            </div>
            <div class="col-md-3">
              <label for="inicio" class="form-label"><b>Folio inicial</b></label>
              <input type="number" v-model.number="form.inicio" id="inicio" class="form-control" required @keyup.enter="focusNext('final')">
            </div>
            <div class="col-md-3">
              <label for="final" class="form-label"><b>Folio final</b></label>
              <input type="number" v-model.number="form.final" id="final" class="form-control" required @keyup.enter="focusNext('submit')">
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label class="form-label"><b>Ordenado por</b></label>
              <div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="orden1" value="lote" v-model="form.orden">
                  <label class="form-check-label" for="orden1">Número de lote (para envío de actas)</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="orden2" value="vigentes" v-model="form.orden">
                  <label class="form-check-label" for="orden2">Folio de notificación (solo vigentes)</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="orden3" value="dependencia" v-model="form.orden">
                  <label class="form-check-label" for="orden3">Dependencia y número de acta</label>
                </div>
              </div>
            </div>
            <div class="col-md-6">
              <label class="form-label"><b>Tipo de Documento</b></label>
              <div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="tipoN" value="N" v-model="form.tipo">
                  <label class="form-check-label" for="tipoN">Notificación</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="tipoR" value="R" v-model="form.tipo">
                  <label class="form-check-label" for="tipoR">Requerimiento</label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="tipoS" value="S" v-model="form.tipo">
                  <label class="form-check-label" for="tipoS">Secuestro</label>
                </div>
              </div>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12 text-end">
              <button type="submit" ref="submitBtn" class="btn btn-success">
                <i class="fa fa-print"></i> Imprimir
              </button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="alert alert-info">Cargando...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="result && result.length">
          <h5 class="mt-4">Resultado</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th>Dependencia</th>
                <th>Año Acta</th>
                <th>Número Acta</th>
                <th>Número Lote</th>
                <th>Folio Req</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in result" :key="row.folioreq">
                <td>{{ row.abrevia }}</td>
                <td>{{ row.axo_acta }}</td>
                <td>{{ row.num_acta }}</td>
                <td>{{ row.num_lote }}</td>
                <td>{{ row.folioreq }}</td>
              </tr>
            </tbody>
          </table>
          <div class="mt-2"><b>Total Actas:</b> {{ result.length }}</div>
        </div>
        <div v-else-if="result && !result.length" class="alert alert-warning mt-3">
          No se encontraron resultados para los criterios seleccionados.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListaNotificacionesPage',
  data() {
    return {
      form: {
        reca: '',
        axo: '',
        inicio: '',
        final: '',
        tipo: 'N',
        orden: 'lote'
      },
      loading: false,
      error: '',
      result: null
    };
  },
  methods: {
    focusNext(field) {
      this.$nextTick(() => {
        if (field === 'axo') this.$el.querySelector('#axo').focus();
        else if (field === 'inicio') this.$el.querySelector('#inicio').focus();
        else if (field === 'final') this.$el.querySelector('#final').focus();
        else if (field === 'submit') this.$refs.submitBtn.focus();
      });
    },
    async onSubmit() {
      this.loading = true;
      this.error = '';
      this.result = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'listanotificaciones_report',
            params: {
              reca: this.form.reca,
              axo: this.form.axo,
              inicio: this.form.inicio,
              final: this.form.final,
              tipo: this.form.tipo,
              orden: this.form.orden
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.result = data.data;
        } else {
          this.error = data.message || 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.listanotificaciones-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 20px;
}
.card-header {
  font-size: 1.2rem;
  font-weight: bold;
}
</style>
